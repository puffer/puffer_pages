class PagesController < ApplicationController
  unloadable

  def index
    page = PufferPages::Page.find_page(request.path_info)
    render puffer_page: page, content_type: page.try(:content_type)
  end
end
