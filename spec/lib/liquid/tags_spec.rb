require 'spec_helper'

describe 'Tags' do

  def render_page(page, drops = {})
    page.render({ self: page }.merge(drops))
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

  describe 'javascript' do

    it 'should render javascript tag' do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% javascript %}\nvar i = \"\";\ni = 2;\n{% endjavascript %}"
      render_page(@page).should == "<%= javascript_tag do %>\nvar i = \"\";\ni = 2;\n<% end %>"
    end

  end

  describe 'super' do
    let!(:root){
      Fabricate :page, :layout_name => 'foo', :page_parts => [
        Fabricate(:page_part, :name => 'sidebar', :body => "root sidebar {{var}}")
      ]
    }
    let!(:page){
      Fabricate :page, :slug => 'page', :parent => root, :page_parts => [
        Fabricate(:page_part, :name => 'sidebar', :body => "wrap {% super var:'hello' %} sidebar")
      ]
    }
    let!(:page2){
      Fabricate :page, :slug => 'page2', :parent => page, :page_parts => [
        Fabricate(:page_part, :name => 'sidebar', :body => "wrap2 {% super %} sidebar")
      ]
    }

    specify{page.render("{% include 'sidebar' %}").should == "wrap root sidebar hello sidebar"}
    specify{page2.render("{% include 'sidebar' %}").should == "wrap2 wrap root sidebar hello sidebar sidebar"}
  end

  describe 'array' do
    subject{Liquid::Template.parse("{% array arr = 'one', 2, var %}{{arr[0]}} {{arr[1]}} {{arr[2]}}")}
    specify{subject.render('var' => 'three').should == 'one 2 three'}
  end

  context 'url helpers' do
    include RSpec::Rails::ControllerExampleGroup

    controller{}

    def render template, variables = {}
      Liquid::Template.parse(template).render!(variables.stringify_keys, {:registers => {:controller => controller}})
    end

    specify { render("{% url admin_pages %}").should == 'http://test.host/admin/pages' }
    specify { render("{% path admin_page 10 %}").should == '/admin/pages/10' }
    specify { render("{% path admin_pages key: 'value' %}").should == '/admin/pages?key=value' }
    specify { render("{% path admin_page 'haha' %}").should == '/admin/pages/haha' }
    specify { render("{% path admin_page var %}", { var: 'foo' }).should == '/admin/pages/foo' }
    specify { render("{% path admin_page 10, key: value %}", { value: 'hello' }).should == '/admin/pages/10?key=hello' }
  end
end
