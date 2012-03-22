class PostsController < ApplicationController

  def foo
    render 'moo/bar', :layout => 'puffer_pages'
  end

  def fooo
    render :puffer_page => 'moo/bar'
  end

  def moo
    render :puffer_page => 'moo'
  end

  def bar
    @page = Page.find_page 'bar'
    render :puffer_page => @page
  end

end