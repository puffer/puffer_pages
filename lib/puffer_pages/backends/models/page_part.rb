class PufferPages::Backends::PagePart < ActiveRecord::Base
  include ActiveUUID::UUID
  include PufferPages::Backends::Mixins::Renderable
  include PufferPages::Backends::Mixins::Importable
  include PufferPages::Backends::Mixins::Translatable
  self.abstract_class = true
  self.table_name = :page_parts

  attr_protected

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :page_id

  belongs_to :page, :class_name => '::PufferPages::Page', :inverse_of => :page_parts

  before_validation :defaultize_attributes
  def defaultize_attributes
    self.handler ||= 'html'
  end

  def main?
    name == PufferPages.primary_page_part_name
  end

  def parent
    ancestors.first
  end

  def ancestors
    page.ancestors_page_parts.where(name: name)
  end

  def self_and_ancestors
    page.self_and_ancestors_page_parts.where(name: name)
  end

  def render *args
    _, context = normalize_render_options *args
    render_template body, context, additional_render_options
  end

  def handle *args
    _, context = normalize_render_options *args
    PufferPages::Handlers.process handler || 'html', self, context
  end

  def additional_render_options
    { environment: { processed: self } }
  end

  def page_segments
    @page_segments ||= page.segments
  end

  def i18n_scope
    i18n_scope_for page_segments
  end

  def i18n_defaults
    page_segments[0..-2].each_with_object([[]]) { |segment, result| result.push result.last + [segment] }.reverse.
      map { |segments| i18n_scope_for(segments) }
  end

private

  def i18n_scope_for *segments
    [:pages, *segments.flatten.map(&:to_sym)]
  end
end
