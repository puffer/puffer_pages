class ContextTestDrop < ::Liquid::Drop
  def registers_page
    @context.registers[:drops_page].name
  end
end

class ArticlesController < ApplicationController

  layout :puffer_pages

  def show
    @article = Article.where(:slug => params[:id]).first
  end

  def foo
    render 'moo/bar', :layout => 'puffer_pages'
  end

  def moo
    render 'moo'
  end

  def bar
    @page = Page.find_page 'bar'
    render @page
  end

  def baz
    render :text => 'rendered text'
  end

  def drops
    @drops_page = Page.find_page 'drops'
    @first = 1
    @second = 'two'
    @drop = ContextTestDrop.new
    render @drops_page
  end

end
