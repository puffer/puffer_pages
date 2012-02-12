class ArticlesController < ApplicationController

  layout :puffer_pages

  def show
    @article = Article.where(:slug => params[:id]).first
  end

  def foo
    render '/moo/bar', :layout => 'puffer_pages'
  end

end
