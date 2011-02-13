class Page < ActiveRecord::Base

  acts_as_nested_set

  scope :with_parts, includes(:page_parts)
  scope :published, where(:status => 'published')
  default_scope order(:lft)

  def self.statuses
    %w(draft hidden published)
  end

  def self.root
    roots.first
  end

  def self.find_page location
    page = Page.find_by_location location
    raise ActiveRecord::RecordNotFound if page.nil? || page.draft?
    page
  end

  has_many :page_parts, :order => "name = '#{PufferPages.primary_page_part_name}' desc, name", :dependent => :destroy
  accepts_nested_attributes_for :page_parts, :allow_destroy => true
  belongs_to :layout, :primary_key => :name, :foreign_key => :layout_name

  validates_presence_of :name
  validate do |page|
    page.errors.add(:layout_name, :blank) unless page.inherited_layout_name.present?
  end
  validates_uniqueness_of :slug, :scope => :parent_id
  validates_format_of :slug,
    :with => /\A([\w]+[\w-]*(\.[\w]+)?|\*)\Z/,
    :message => :slug_format,
    :unless => :root?
  validates_format_of :slug,
    :with => /\A\Z/,
    :message => :root_slug_format,
    :if => :root?
  validates_inclusion_of :status, :in => Page.statuses

  attr_protected :location

  before_validation :set_status
  def set_status
    self.status ||= 'draft'
  end

  before_save :update_location
  def update_location
    self.location = [swallow_nil{parent.location}, slug].compact.join('/').presence
  end

  before_update :update_locations
  def update_locations
    Page.update_all "location = replace(location, '#{location_was}', '#{location}')", ["location like ?", location_was + '%'] if location_changed?
  end

  after_save :create_main_part
  def create_main_part
    page_parts.create(:name => PufferPages.primary_page_part_name) if root?
  end

  statuses.each do |status_name|
    define_method "#{status_name}?" do status == status_name end
  end

  def render(drops_or_context)
    if inherited_layout
      @template = Liquid::Template.parse(inherited_layout.body)
      tracker.cleanup @template.render(drops_or_context, :registers => {:tracker => tracker, :page => self, :file_system => PufferPages::Liquid::FileSystem.new})
    else
      inherited_page_parts.map{|part| part.render(drops_or_context, self)}.join
    end
  end

  def tracker
    @tracker ||= PufferPages::Liquid::Tracker.new
  end

  def inherited_layout_page
    @inherited_layout_page ||= layout_name? ? self : swallow_nil{parent.inherited_layout_page}
  end

  def inherited_layout_name
    @inherited_layout_name ||= swallow_nil{inherited_layout_page.layout_name}
  end

  def inherited_layout
    @inherited_layout ||= swallow_nil{inherited_layout_page.layout}
  end

  def render_layout
    inherited_layout ? false : inherited_layout_name
  end

  def inherited_page_parts
    PagePart.where(:page_parts => {:page_id => self_and_ancestors.map(&:id)}).joins(:page).order("page_parts.name = '#{PufferPages.primary_page_part_name}' desc, page_parts.name, pages.lft desc").uniq_by &:name
  end

  def part name
    inherited_page_parts.detect {|part| part.name == name}
  end

  def is_layout?
    self.location.include?('*')
  end

  def content_type
    Rack::Mime.mime_type(File.extname(slug), 'text/html')
  end

end
