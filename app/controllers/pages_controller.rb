class PagesController < ApplicationController
  layout :puffer_pages

  def index
    page = Page.find_page(params[:path])
    @self = page.to_drop(self)
    render page, :content_type => page.content_type
  end
end
