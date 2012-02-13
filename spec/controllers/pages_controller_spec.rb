require 'spec_helper'

describe PagesController do

  describe "GET index" do
    render_views

    before :each do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include 'body' %}"
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @root.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'hello from @root')]
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @foo.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'hello from @foo')]
      @bar = Fabricate :page, :slug => 'bar.css', :parent => @foo
      @bar.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'hello from @bar')]
    end

    it 'should render root page' do
      get :index
      response.body.should == 'hello from @root'
    end

    it 'should render non-root page' do
      get :index, :path => 'foo'
      response.body.should == 'hello from @foo'
    end

    it 'should return proper content-type' do
      get :index, :path => 'foo/bar.css'
      response.body.should == 'hello from @bar'
      response.content_type.should == 'text/css'
    end
  end

end
