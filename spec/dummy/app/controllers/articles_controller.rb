class ArticlesController < ApplicationController

  layout :puffer_pages

  def show
    @article = Article.where(:slug => params[:id]).first
  end

end
