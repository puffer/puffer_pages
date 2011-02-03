class PagesController < ApplicationController

  def index
    @page = Page.find_page("/#{params[:path]}")
    render :inline => @page.render(drops), :layout => @page.render_layout, :content_type => page.content_type
  end

  private

  def drops
    {
      :self => PufferPages::Liquid::PageDrop.new(@page, request),
      :root => PufferPages::Liquid::PageDrop.new(Page.root, request)
    }.stringify_keys
  end

end
