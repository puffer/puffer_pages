class PagesController < ApplicationController

  def index
    @page = Page.find_page params[:path]
    render :inline => @page.render(drops), :layout => @page.render_layout, :content_type => @page.content_type
  end

  private

  def drops
    {
      :self => PufferPages::Liquid::PageDrop.new(@page, @page, self),
      :root => PufferPages::Liquid::PageDrop.new(@page.root, @page, self)
    }.stringify_keys
  end

end
