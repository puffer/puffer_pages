require 'spec_helper'

describe 'Drops' do

  include RSpec::Rails::RequestExampleGroup

  def render_page(current_page, page = nil)
    get "/#{current_page.location}"
    current_page.render 'self' => current_page.to_drop(current_page, controller),
      'page' => (page.to_drop(current_page, controller) if page)
  end

  describe 'page drop' do

    before :each do
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @foo = Fabricate :page, :slug => 'hello', :parent => @root
      @bar = Fabricate :page, :slug => 'world', :parent => @foo
      @root.reload
      @foo.reload
      @bar.reload
    end

    it 'should render proper url and path' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{{ self.path }} {{ self.url }}"

      render_page(@bar).should == '/hello/world http://www.example.com/hello/world'
    end

    it 'should render page_part' do
      @bar.page_parts.create(:name => 'sidebar', :body => "{{ 'hello!' }}")
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{{ self.sidebar }}"

      render_page(@bar).should == "hello!"
    end

    it 'should render proper current?' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{{ page.current? }}"

      render_page(@foo, @foo).should == 'true'
      render_page(@foo, @root).should == 'false'
      render_page(@foo, @bar).should ==  'false'
    end

    it 'should render proper ancestor?' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{{ page.ancestor? }}"

      render_page(@foo, @foo).should == 'false'
      render_page(@foo, @root).should == 'true'
      render_page(@foo, @bar).should ==  'false'
    end

  end

end
