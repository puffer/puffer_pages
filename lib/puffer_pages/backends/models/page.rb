# encoding: UTF-8
class PufferPages::Backends::Page < ActiveRecord::Base
  include ActiveUUID::UUID
  include PufferPages::Backends::Mixins::Renderable
  include PufferPages::Backends::Mixins::Importable
  include PufferPages::Backends::Mixins::Localable
  self.abstract_class = true
  self.table_name = :pages

  attr_protected :location

  def self.inherited base
    base.acts_as_nested_set
    super
  end

  scope :published, where(:status => 'published')

  def self.statuses
    %w(draft hidden published)
  end

  def self.controller_scope scope
    where scope
  end

  def self.normalize_path path
    path.to_s.split('/').delete_if(&:blank?).join('/').presence
  end

  def self.find_page location
    location = normalize_path(location)
    PufferPages.single_section_page_path ?
      find_by_slug(location) : find_by_location(location)
  end

  def self.find_view_page location, options = {}
    location = normalize_path(location)
    depth = location.to_s.count('/').next
    formats = options[:formats].presence || [:html]

    if location.blank?
      roots.first
    else
      formats.inject(nil) do |page, format|
        page ||= begin
          loc = if format == :html
            where(['? like location', location])
          else
            where(['? like location', [location, format].join('.')]).where(['not ? like location', [location, format, ''].join('.')])
          end
          loc.where(:"#{depth_column_name}" => depth).order('lft desc').first
        end
      end
    end
  end

  def self.export_json
    includes(:page_parts).order(:lft).as_json(
      include: :page_parts, except: [:lft, :rgt, :depth, :location]
    )
  end

  def self.import_destroy
    roots.destroy_all
  end

  has_many_page_parts_options = {
    order: "name = '#{PufferPages.primary_page_part_name}' desc, name",
    dependent: :destroy,
    class_name: '::PufferPages::PagePart',
    validate: true,
    inverse_of: :page
  }
  has_many_page_parts_options.merge!(include: :translations) if PufferPages.localize

  has_many :page_parts, has_many_page_parts_options

  accepts_nested_attributes_for :page_parts, :allow_destroy => true
  belongs_to :layout, :primary_key => :name, :foreign_key => :layout_name, :class_name => 'PufferPages::Layout'

  validates_presence_of :name
  validates_uniqueness_of :slug,
    :scope => (:parent_id unless PufferPages.single_section_page_path), :allow_nil => true
  validates_inclusion_of :status, :in => statuses
  validates_format_of :slug,
    :with => /\A\s*\Z/, :message => :root_slug_format, :if => :root?
  validates_format_of :slug,
    :with => /\A([^\/]+)\Z/, :message => :slug_format, :unless => :root?
  validate do |page|
    page.errors.add(:layout_name, :blank) if page.inherited_layout_name.nil?
  end

  before_validation :defaultize_attributes
  def defaultize_attributes
    self.status ||= 'draft'
    self.slug = slug.presence
    self.location = [parent.try(:location), slug].compact.join('/').presence
  end

  def location
    read_attribute(:location) || [parent.try(:location), slug].compact.join('/').presence
  end

  before_update :update_locations, :if => :location_changed?
  def update_locations
    self.class.update_all "location = replace(location, '#{location_was}', '#{location}')", ["location like ?", location_was + '%']
  end

  statuses.each do |status_name|
    define_method "#{status_name}?" do status == status_name end
  end

  def status
    ActiveSupport::StringInquirer.new(read_attribute(:status)) if status?
  end

  def segments
    location.to_s.split ?/
  end

  def to_location
    PufferPages.single_section_page_path ? slug : location
  end

  def format
    File.extname(slug)[1..-1].to_s.to_sym.presence || :html
  end

  def ancestors_page_parts
    self_and_ancestors_page_parts.where('pages.id != ?', id)
  end

  def self_and_ancestors_page_parts
    PufferPages::PagePart
      .where("#{q_left} <= ? AND #{q_right} >= ?", left, right)
      .joins(:page).order('name, pages.lft desc')
  end

  def inherited_page_parts
    @inherited_page_parts ||= begin
      page_parts = self_and_ancestors_page_parts.group_by(&:name)
      if PufferPages.localize
        translation_cached = page_parts.values.map { |group| group.first.handler == 'yaml' ? group : group.first }.
          flatten.index_by(&:id)
        PufferPages::PagePart::Translation.where(page_part_id: translation_cached.keys).
          with_locale(Globalize.fallbacks).each do |translation|
          translation_cached[translation.page_part_id].translation_caches[translation.locale.to_sym] = translation
        end
      end
      page_parts
    end
  end

  def inherited_page_part name
    inherited_page_parts[name].first
  end

  def render *args
    source, context = normalize_render_options *args
    context = merge_context context, additional_render_options
    source ||= inherited_layout

    contextualize page_translations: page_translations do
      if source
        if source.respond_to?(:render)
          instrument_render! context do
            source.render context
          end
        else
          render_template source, context
        end
      else
        instrument_render! context do
          inherited_page_parts.values.map(&:first).map do |part|
            result = part.render context
            part.main? ? result : "<% content_for :'#{part.name}' do %>#{result}<% end %>"
          end.join
        end
      end
    end
  end

  def locales_translations; locales; end
  def locales_translations=(value); self.locales = value; end

  def page_translations
    self_and_ancestors.each_with_object({}) do |page, result|
      result.deep_merge! page.locales.translations
    end
  end

  def additional_render_options
    { registers: { page: self }, drops: { page: self, self: self }, environment: { processed: self } }
  end

  def inherited_layout_page
    @inherited_layout_page ||= layout_name? ? self : parent.try(:inherited_layout_page)
  end

  def inherited_layout_name
    @inherited_layout_name ||= inherited_layout_page.try(:layout_name)
  end

  def current_layout
    @current_layout ||= inherited_layout_page.try(:layout)
  end

  def inherited_layout
    @inherited_layout ||= PufferPages::Layout.find_layout(current_layout.name) if current_layout
  end

  def layout_for_render
    "layouts/#{inherited_layout_name}" unless inherited_layout
  end

  def content_type
    Rack::Mime.mime_type(File.extname(slug.to_s), 'text/html')
  end

  def to_liquid
    @to_liquid ||= ::PufferPages::Liquid::PageDrop.new(self)
  end
end
