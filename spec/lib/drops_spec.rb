require 'spec_helper'

describe 'Drops' do

  def render_page(current_page, page = nil)
    request = ActionController::TestRequest.new
    request.env["rack.url_scheme"] = "http"
    request.host = 'test.com'
    request.port = 80
    request.path = "/#{current_page.location}"
    current_page.render 'self' => PufferPages::Liquid::PageDrop.new(current_page, current_page, request),
      'page' => (PufferPages::Liquid::PageDrop.new(page, current_page, request) if page)
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

      render_page(@bar).should == '/hello/world http://test.com/hello/world'
    end

    it 'should render page_part' do
      @bar.page_parts.create(:name => 'sidebar', :body => "{{ 'hello!' }}")
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{{ self.sidebar }}"

      render_page(@bar).should == "{{ 'hello!' }}"
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
