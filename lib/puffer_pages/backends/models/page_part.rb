class PufferPages::PagePart < ActiveRecord::Base
  self.abstract_class = true

  belongs_to :page, :class_name => '::Page'

  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :page_id

  def render drops_or_context, options = {}, page = page
    template = Liquid::Template.parse(body)

    if drops_or_context.is_a?(Hash) && (drops_or_context.key?(:drops) || drops_or_context.key?(:registers))
      drops = drops_or_context[:drops] || {}
      registers = drops_or_context[:registers] || {}
    else
      drops = drops_or_context
      registers = {}
    end
    drops.stringify_keys!

    result = tracker.cleanup template.render(drops, :registers => {
      :tracker => tracker,
      :page => page,
      :file_system => PufferPages::Liquid::FileSystem.new
    }.reverse_merge!(registers))
    main? ? result : "<% content_for :'#{name}' do %>#{result}<% end %>"
  end

  def tracker
    @tracker ||= PufferPages::Liquid::Tracker.new
  end

  def main?
    name == PufferPages.primary_page_part_name
  end

end
