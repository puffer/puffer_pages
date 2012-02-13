class PagesController < ApplicationController
  layout :puffer_pages

  def index
    @puffer_page = Page.find_page params[:path]
  end

end
