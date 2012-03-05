class PufferPages::PagePart < ActiveRecord::Base
  include PufferPages::Renderable
  self.abstract_class = true

  belongs_to :page, :class_name => '::Page'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :page_id

  def render drops_or_context, page = page
    result = render_template(body, page, drops_or_context)
    main? ? result : "<% content_for :'#{name}' do %>#{result}<% end %>"
  end

  def main?
    name == PufferPages.primary_page_part_name
  end

end
