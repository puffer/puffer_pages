class Snippet < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def render(drops_or_context)
    template = Liquid::Template.parse(body)
    tracker.cleanup template.render(drops_or_context, :registers => {:tracker => tracker})
  end

  def tracker
    @tracker ||= PufferPages::Liquid::Tracker.new
  end

end
