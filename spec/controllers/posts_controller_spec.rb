require 'spec_helper'

describe PostsController do

  describe "GET foo" do

    before :each do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include 'body' %}"
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @moo = Fabricate :page, :slug => 'moo', :parent => @root
      @moo.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'hello from @moo')]
      @bar = Fabricate :page, :slug => 'bar', :parent => @moo
      @bar.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'hello from @bar')]
    end

    it "render @bar content" do
      get :foo
      response.body.should == "hello from @bar"
    end

    it "render @bar content" do
      get :fooo
      response.body.should == "hello from @bar"
    end

    it "render @moo content" do
      get :moo
      response.body.should == "hello from @moo"
    end
  end

  describe "GET bar" do

    before :each do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include 'body' %}"
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @bar = Fabricate :page, :slug => 'bar', :parent => @root, :status => 'published'
      @bar.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'hello from @bar')]
    end

    it "render found page" do
      get :bar
      response.body.should == "hello from @bar"
    end

    it "render found page" do
      expect{get(:baz)}.to raise_error(ActionView::MissingTemplate)
    end
  end

end
