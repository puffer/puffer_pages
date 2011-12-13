class PagesController < ApplicationController

  def index
    @page = Page.find_page params[:path]
    render :inline => @page.render(default_drops(@page)), :layout => @page.render_layout, :content_type => @page.content_type
  end

end
