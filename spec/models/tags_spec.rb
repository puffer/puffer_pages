require 'spec_helper'

describe 'Tags' do

  def render_page(page)
    page.render 'self' => PufferPages::Liquid::PageDrop.new(page)
  end

  describe 'yield' do

    before :each do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @main = Fabricate :page_part, :name => PufferPages.primary_page_part_name, :body => 'foo'
      @sidebar = Fabricate :page_part, :name => 'sidebar', :body => 'bar'
      @page.page_parts = [@main, @sidebar]
    end

    it 'should render yield without params' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% yield %}"
      render_page(@page).should == @main.body
    end

    it 'should render yield with string param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% yield 'sidebar' %}"
      render_page(@page).should == @sidebar.body
    end

    it 'should render yield with variable param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign sb = 'sidebar' %}{% yield sb %}"
      render_page(@page).should == @sidebar.body
    end

  end

  describe 'render_snippet' do

    before :each do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @snippet = Fabricate :snippet, :name => 'snip', :body => 'snippet body'
    end

    it 'should render yield with string param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% render_snippet 'snip' %}"
      render_page(@page).should == @snippet.body
    end

    it 'should render yield with variable param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign sn = 'snip' %}{% render_snippet sn %}"
      render_page(@page).should == @snippet.body
    end

  end


end
