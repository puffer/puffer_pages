require 'spec_helper'

describe 'Tags' do

  def render_page(page, drops = {})
    page.render({'self' => PufferPages::Liquid::PageDrop.new(page)}.merge(drops))
  end

  describe 'include page part' do

    before :each do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @main = Fabricate :page_part, :name => PufferPages.primary_page_part_name, :body => 'foo'
      @sidebar = Fabricate :page_part, :name => 'sidebar', :body => 'bar'
      @page.page_parts = [@main, @sidebar]
    end

    it 'should include page_part with string param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include '#{PufferPages.primary_page_part_name}' %}"
      render_page(@page).should == @main.body
    end

    it 'should include page_part with variable param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign sb = 'sidebar' %}{% include sb %}"
      render_page(@page).should == @sidebar.body
    end

  end

  describe 'include snippet' do

    before :each do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @snippet = Fabricate :snippet, :name => 'snip', :body => 'snippet body'
    end

    it 'should include snippet with string param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include 'snippets/snip' %}"
      render_page(@page).should == @snippet.body
    end

    it 'should include snippet with variable param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign sn = 'snippets/snip' %}{% include sn %}"
      render_page(@page).should == @snippet.body
    end

    it 'should include snippet with proper object name' do
      @snippet = Fabricate :snippet, :name => 'var', :body => '{{ var }}'
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign sn = 'snippets/var' %}{% include sn with var:'hello' %}"
      render_page(@page).should == 'hello'
    end

  end

  describe 'stylesheets' do

    it 'should render stylesheets with proper params' do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign st = 'styles' %}{% stylesheets 'reset', st %}"
      render_page(@page).should == "<%= stylesheet_link_tag 'reset', 'styles' %>"
    end

  end

  describe 'javascripts' do

    it 'should render javascripts with proper params' do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% assign ctrl = 'controls' %}{% javascripts 'prototype', ctrl %}"
      render_page(@page).should == "<%= javascript_include_tag 'prototype', 'controls' %>"
    end

  end
end
