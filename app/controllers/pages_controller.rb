class PagesController < ApplicationController
  layout :puffer_pages

  def index
    page = Page.find_page(params[:path])
    render page, :content_type => page.content_type, :layout => true
  end
end
