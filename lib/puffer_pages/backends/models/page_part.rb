class PufferPages::PagePart < ActiveRecord::Base
  include PufferPages::Renderable
  self.abstract_class = true

  belongs_to :page, :class_name => '::Page', :inverse_of => :page_parts

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:page_id, :locale]

  after_initialize do |page_part|
    page_part.locale = I18n.default_locale if page_part.locale.blank?
  end

  def render context = {}, page = page
    render_liquid(body, page, context)
  end

  def main?
    name == PufferPages.primary_page_part_name
  end

  def super_part
    @super_part ||= page.super_inherited_page_parts.uniq_by(&:name).detect {|part| part.name == name}
  end

  def source
    body
  end
end
