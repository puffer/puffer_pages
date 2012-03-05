require 'spec_helper'

describe ArticlesController do

  describe "GET show" do
    render_views

    before :each do
      @layout = Fabricate :layout, :name => 'foo_layout'
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @articles_page = Fabricate :page, :slug => 'articles', :parent => @root
      @articles_wildcard = Fabricate :page, :slug => '%', :parent => @articles_page

      @article = Fabricate :article, :title => 'foo', :body => 'bar'
    end

    it "assigns @article" do
      get :show, :id => 'foo'

      assigns(:article).should == @article
    end

    it "renders the show template" do
      get :show, :id => 'foo'

      response.should render_template("show")
    end

    it "renders yield with db layout" do
      @layout.update_attributes :body => 'db - {% yield %} - db'
      get :show, :id => 'foo'

      response.body.should == 'db - foo - db'
    end

    it "renders yield with app layout" do
      @root.update_attributes :layout_name => 'articles'
      get :show, :id => 'foo'

      response.body.should == 'app -  - app'
    end

    it "renders yield with app and db placeholder" do
      @root.update_attributes :layout_name => 'articles'
      @articles_wildcard.page_parts = [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'db - {% yield %} - db')]
      get :show, :id => 'foo'

      response.body.should == 'app - db - foo - db - app'
    end

    it "renders yield with param" do
      @root.update_attributes :layout_name => 'articles'
      @articles_wildcard.page_parts = [
        Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => 'db - {% yield hello %} - db'),
        Fabricate(:page_part, :name => 'hello', :body => 'hello - {% yield %} - hello')
      ]
      get :show, :id => 'foo'

      response.body.should == 'app - db - hello - foo - hello - db - app'
    end

  end

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
  end

  describe "Drops assign" do
    before :each do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{{first}} {{second}} {{page}} {{drop.registers_page}}"
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @drops = Fabricate :page, :slug => 'drops', :name => 'drops_page', :parent => @root, :status => 'published'
    end

    it "assigns all" do
      get :drops
      response.body.should == "1 two  drops_page"
    end
  end

end
