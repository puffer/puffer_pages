require 'spec_helper'

describe 'Tags' do

  def render_page(page, drops = {})
    page.render({'self' => page.to_drop}.merge(drops))
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

    it 'should include snippet with string param' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% snippet 'snip' %}"
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

  describe 'javascript' do

    it 'should render javascript tag' do
      @page = Fabricate :page, :layout_name => 'foo_layout'
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% javascript %}\nvar i = \"\";\ni = 2;\n{% endjavascript %}"
      render_page(@page).should == "<%= javascript_tag do %>\nvar i = \"\";\ni = 2;\n<% end %>"
    end

  end

  describe 'attributes: name, title, keywords, description' do

    it 'should render self title without params' do
      @page = Fabricate :page, :layout_name => 'foo_layout', :name => 'hello', :title => '{{self.name}}',
        :page_parts => [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => '{% title %}')]
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include '#{PufferPages.primary_page_part_name}' %}"

      render_page(@page).should == "hello"
    end

    it 'should render page title with param and should get page drop as self internally' do
      @root = Fabricate :page, :layout_name => 'foo_layout', :name => 'hello', :title => '{{self.name}}',
        :page_parts => [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => '{% title page %}')]
      @page = Fabricate :page, :parent => @root, :slug => 'foo', :name => 'world', :title => '{{self.name}}'
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include '#{PufferPages.primary_page_part_name}' %}"

      render_page(@root, 'page' => PufferPages::Liquid::PageDrop.new(@page)).should == "world"
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

    specify{page.render_layout("{% include 'sidebar' %}").should == "wrap root sidebar hello sidebar"}
    specify{page2.render_layout("{% include 'sidebar' %}").should == "wrap2 wrap root sidebar hello sidebar sidebar"}
  end

  describe 'array' do
    subject{Liquid::Template.parse("{% array arr = 'one', 2, var %}{{arr[0]}} {{arr[1]}} {{arr[2]}}")}
    specify{subject.render('var' => 'three').should == 'one 2 three'}
  end

  context 'url helpers' do
    include RSpec::Rails::ControllerExampleGroup

    controller{}

    def render template, variables = {}
      Liquid::Template.parse(template).render(variables.stringify_keys, {:registers => {:controller => controller}})
    end

    specify{render("{% url foo_posts %}").should == 'http://test.host/posts/foo'}
    specify{render("{% path foo_posts %}").should == '/posts/foo'}
    specify{render("{% path foo_posts key:'value' %}").should == '/posts/foo?key=value'}
    specify{render("{% path article 10 %}").should == '/articles/10'}
    specify{render("{% path article 'haha' %}").should == '/articles/haha'}
    specify{render("{% path article var %}", {:var => 'foo'}).should == '/articles/foo'}
    specify{render("{% path article 10, key:value %}", {:value => 'hello'}).should == '/articles/10?key=hello'}
  end
end
