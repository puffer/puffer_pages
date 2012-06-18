# encoding: UTF-8
class PufferPages::Page < ActiveRecord::Base
  include PufferPages::Renderable
  self.abstract_class = true

  def self.inherited base
    base.acts_as_nested_set
    super
  end

  scope :published, where(:status => 'published')

  def self.statuses
    %w(draft hidden published)
  end

  def self.controller_scope scope
    where(scope)
  end

  def self.normalize_path path
    path.to_s.split('/').delete_if(&:blank?).join('/').presence
  end

  def self.find_page location
    location = normalize_path(location)
    page = PufferPages.single_section_page_path ?
      find_by_slug(location) : find_by_location(location)
    raise ActiveRecord::RecordNotFound unless page
    raise PufferPages::DraftPage.new("PufferPages can`t show page `#{page.location}` because it is draft") if page.draft?
    page
  end

  def self.find_view_page location, options = {}
    location = normalize_path(location)
    formats = options[:formats].presence || [:html]

    page = if location.blank?
      roots.first
    else
      formats.inject(nil) do |page, format|
        unless page
          loc = format == :html ? location : [location, format].join('.')
          page = where(['? like location', loc]).where(['status not in (?)', 'draft']).order('lft desc').first
        end
      end
    end

    raise PufferPages::LayoutMissed.new(
      "PufferPages can`t render page for `#{location}` with formats `#{formats.join('`, `')}` because layout page missed or draft"
    ) unless page
    page
  end

  def self.to_drop *args
    map{|page| page.to_drop(*args)}
  end

  has_many :page_parts,
    :order => "name = '#{PufferPages.primary_page_part_name}' desc, name",
    :dependent => :destroy,
    :class_name => '::PagePart',
    :validate => true,
    :inverse_of => :page
  accepts_nested_attributes_for :page_parts, :allow_destroy => true
  belongs_to :layout, :primary_key => :name, :foreign_key => :layout_name, :class_name => '::Layout'

  validates_presence_of :name
  validates_uniqueness_of :slug,
    :scope => (:parent_id unless PufferPages.single_section_page_path), :allow_nil => true
  validates_inclusion_of :status, :in => statuses
  validates_format_of :slug,
    :with => /\A\s*\Z/, :message => :root_slug_format, :if => :root?
  validates_format_of :slug,
    :with => /\A([^\/]+)\Z/, :message => :slug_format, :unless => :root?
  validate do |page|
    page.errors.add(:layout_name, :blank) unless page.inherited_layout_name.present?
  end

  attr_protected :location

  before_validation :defaultize_attributes
  def defaultize_attributes
    self.status ||= 'draft'
    self.slug = slug.presence
    self.location = [swallow_nil{parent.location}, slug].compact.join('/').presence
  end

  before_update :update_locations, :if => :location_changed?
  def update_locations
    self.class.update_all "location = replace(location, '#{location_was}', '#{location}')", ["location like ?", location_was + '%']
  end

  after_initialize :build_main_part, :if => :root?
  before_save :build_main_part, :if => :root?
  def build_main_part
    page_parts.build(:name => PufferPages.primary_page_part_name) unless page_parts.map(&:name).include?(PufferPages.primary_page_part_name)
  end

  statuses.each do |status_name|
    define_method "#{status_name}?" do status == status_name end
  end

  def to_location
    PufferPages.single_section_page_path ? slug : location
  end

  def render context = {}
    if inherited_layout
      render_layout(inherited_layout.body, context)
    else
      inherited_page_parts.reverse.map{|part|
        result = part.render(context, self)
        part.main? ? result : "<% content_for :'#{part.name}' do %>#{result}<% end %>"
      }.join
    end
  end

  def render_layout layout, context = {}
    render_liquid(layout, self, context)
  end

  def inherited_layout_page
    @inherited_layout_page ||= layout_name? ? self : parent.try(:inherited_layout_page)
  end

  def inherited_layout_name
    @inherited_layout_name ||= inherited_layout_page.try(:layout_name)
  end

  def inherited_layout
    @inherited_layout ||= inherited_layout_page.try(:layout)
  end

  def layout_for_render
    "layouts/#{inherited_layout_name}" unless inherited_layout
  end

  def inherited_page_parts
    @inherited_page_parts ||= all_inherited_page_parts.uniq_by(&:name)
  end

  def all_inherited_page_parts
    @all_inherited_page_parts ||= ::PagePart.where(:page_parts => {:page_id => self_and_ancestors.map(&:id)}).joins(:page).order("page_parts.name = '#{PufferPages.primary_page_part_name}' desc, page_parts.name, pages.lft desc")
  end

  def super_inherited_page_parts
    @super_inherited_page_parts ||= ::PagePart.where(:page_parts => {:page_id => ancestors.map(&:id)}).joins(:page).order("page_parts.name = '#{PufferPages.primary_page_part_name}' desc, page_parts.name, pages.lft desc")
  end

  def part name
    inherited_page_parts.detect {|part| part.name == name}
  end

  def content_type
    Rack::Mime.mime_type(File.extname(slug.to_s), 'text/html')
  end

  def to_drop *args
    ::PufferPages::Liquid::PageDrop.new(self, *args)
  end
end
