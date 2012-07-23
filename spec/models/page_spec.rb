# encoding: UTF-8
require 'spec_helper'

describe Page do

  describe '.normalize_path' do
    specify{Page.normalize_path(nil).should == nil}
    specify{Page.normalize_path('').should == nil}
    specify{Page.normalize_path('/').should == nil}
    specify{Page.normalize_path('hello').should == 'hello'}
    specify{Page.normalize_path('hello/world').should == 'hello/world'}
    specify{Page.normalize_path('/hello///world//').should == 'hello/world'}
  end

  describe 'attributes' do

    before :each do
      @root = Fabricate :page, :layout_name => 'foo_layout'
    end

    it 'should have nil slug location if root' do
      @root.slug.should == nil
      @root.location.should == nil
    end

    it 'should generate proper location' do
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar
      @foo.location.should == 'foo'
      @bar.location.should == 'foo/bar'
      @baz.location.should == 'foo/bar/baz'
    end

    it 'should check slug uniqueness' do
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'foo', :parent => @foo
      @baz = Fabricate.build :page, :slug => 'foo', :parent => @root
      @foo.should be_valid
      @bar.should be_valid
      @baz.should_not be_valid
    end

    it 'should update descendants locations' do
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar

      @foo.update_attributes :slug => 'moo'

      @foo.reload.location.should == 'moo'
      @bar.reload.location.should == 'moo/bar'
      @baz.reload.location.should == 'moo/bar/baz'

      @bar.update_attributes :slug => 'fuu'

      @foo.reload.location.should == 'moo'
      @bar.reload.location.should == 'moo/fuu'
      @baz.reload.location.should == 'moo/fuu/baz'
    end

  end

  describe 'page parts' do

    before :each do
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo, :page_parts => [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => '4')]
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar, :page_parts => [Fabricate(:page_part, :name => 'sidebar', :body => '5'), Fabricate(:page_part, :name => 'additional', :body => '3')]
      @foo.page_parts = [Fabricate(:page_part, :name => 'sidebar', :body => '2')]
    end

    it 'should receive proper inherited page parts' do
      @root.inherited_page_parts.map(&:body).should == [nil]
      @foo.inherited_page_parts.map(&:body).should == [nil, '2']
      @bar.inherited_page_parts.map(&:body).should == ['4', '2']
      @baz.inherited_page_parts.map(&:body).should == ['4', '3', '5']
    end

  end

  describe 'root page parts' do

    it 'should build default `main` part for root page on initialization' do
      root = Fabricate.build :page, :layout_name => 'foo_layout'
      root.page_parts.map(&:name).should == [PufferPages.primary_page_part_name]
    end

    it 'should create default `main` part for root page' do
      root = Fabricate :page, :layout_name => 'foo_layout'
      root.page_parts.map(&:name).should == [PufferPages.primary_page_part_name]
    end

    it 'should not create `main` part for root page if it exists' do
      root = Fabricate :page, :layout_name => 'foo_layout', :page_parts => [Fabricate.build(:page_part, :name => PufferPages.primary_page_part_name, :body => 'haha')]
      root.page_parts.map(&:name).should == [PufferPages.primary_page_part_name]
      root.page_parts.map(&:body).should == ['haha']
    end

  end

  describe 'layout' do

    before :each do
      @layout = Fabricate :layout, :name => 'bar_layout'
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo, :layout_name => 'bar_layout'
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar
    end

    it 'should receive proper layout name' do
      @root.inherited_layout_name.should == 'foo_layout'
      @foo.inherited_layout_name.should == 'foo_layout'
      @bar.inherited_layout_name.should == 'bar_layout'
      @baz.inherited_layout_name.should == 'bar_layout'
    end

    it 'should return proper layout for render' do
      @root.layout_for_render.should == 'layouts/foo_layout'
      @foo.layout_for_render.should == 'layouts/foo_layout'
      @bar.layout_for_render.should == nil
      @baz.layout_for_render.should == nil
    end

  end

  describe 'rendering' do

    before :each do
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @main = Fabricate :page_part, :name => PufferPages.primary_page_part_name, :body => '{{ self.title }}'
      @sidebar = Fabricate :page_part, :name => 'sidebar', :body => '{{ self.name }}'
      @root.page_parts = [@main, @sidebar]
    end

    it 'should render content_for blocks if rails layout used' do
      result = @root.render 'self' => PufferPages::Liquid::PageDrop.new(@root)
      result.should == "<% content_for :'sidebar' do %>#{@root.name}<% end %>#{@root.title}"
    end

    it 'should render layout' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include 'body' %} {% include 'sidebar' %}"
      result = @root.render 'self' => PufferPages::Liquid::PageDrop.new(@root)
      result.should == "#{@root.title} #{@root.name}"
    end

    it 'should receive proper content type' do
      @root.content_type.should == 'text/html'
      page = Fabricate :page, :slug => 'style.css', :parent => @root
      page.content_type.should == 'text/css'
    end

  end

  describe 'find_page' do

    def single_section_page_path
      PufferPages.single_section_page_path = true
      yield
      PufferPages.single_section_page_path = false
    end

    before :each do
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar, :status => 'draft'
    end

    it 'root page' do
      Page.find_page(nil).should == @root
    end

    it 'not root page' do
      Page.find_page('foo/bar').should == @bar
    end

    it 'not existent page' do
      expect {Page.find_page('foo/baz') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'draft page' do
      expect {Page.find_page('foo/bar/baz') }.to raise_error(PufferPages::DraftPage)
    end

    it 'single section root page' do
      single_section_page_path do
        Page.find_page(nil).should == @root
      end
    end

    it 'single section not root page' do
      single_section_page_path do
        Page.find_page('foo').should == @foo
        Page.find_page('bar').should == @bar
      end
    end

  end

  describe 'find_view_page' do

    before :each do
      @root = Fabricate :page, :layout_name => 'foo_layout'
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => '%', :parent => @foo
      @quux = Fabricate :page, :slug => 'quux', :parent => @bar
      @qux = Fabricate :page, :slug => '%', :parent => @bar # Created before @baz and after @quux
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar
      @bazjs = Fabricate :page, :slug => 'baz.js', :parent => @bar
    end

    it 'root page' do
      Page.find_view_page('/').should == @root
    end

    it 'not root page' do
      Page.find_view_page('/foo').should == @foo
      Page.find_view_page('/foo/bar').should == @bar
      Page.find_view_page('/foo/baz').should == @bar
      Page.find_view_page('/foo/bar/baz').should == @baz
      Page.find_view_page('/foo/moo/baz').should == @baz
    end

    it 'not existent page' do
      expect {Page.find_view_page('/bar')}.to raise_error(PufferPages::LayoutMissed)
    end

    it 'draft page' do
      @bar.update_attributes(:status => 'draft')
      expect {Page.find_view_page('/foo/bar')}.to raise_error(PufferPages::LayoutMissed)
    end

    it "should choose the last created (with the most right tree location) page from those fitting the requested path and format" do
      Page.find_view_page('/foo/moo/baz', :formats => [:html]).should == @baz
    end
    it "should use %-ending locations for html requests with the same priority as locations without % end
        (so in this case the priority is regulated only by tree location)" do
      Page.find_view_page('/foo/moo/quux', :formats => [:html]).should == @qux
    end
    specify {Page.find_view_page('/foo/moo/baz', :formats => [:html, :js]).should == @baz}
    specify {Page.find_view_page('/foo/moo/baz', :formats => [:js]).should == @bazjs}
    specify {Page.find_view_page('/foo/moo/baz', :formats => [:js, :html]).should == @bazjs}
    specify {Page.find_view_page('/foo/moo/baz', :formats => [:xml, :html]).should == @baz}
    specify {Page.find_view_page('/foo/moo/baz', :formats => [:xml, :js]).should == @bazjs}
    it "should not use %-ending locations for formats other than html, thus generating an error if format is different" do
      expect {Page.find_view_page('/foo/moo/baz', :formats => [:xml])}.to raise_error(PufferPages::LayoutMissed)
    end

  end

  context 'renderable attributes' do
    let!(:page_part){
      Fabricate(:page_part,
        :name => PufferPages.primary_page_part_name,
        :body => '{{ self.name }}'
    )}
    let!(:page){
      Fabricate(:page,
        :layout_name => 'foo_layout',
        :name => "{{ self.title }}",
        :title => "hello from title",
        :page_parts => [page_part]
    )}

    specify{page_part.render('self' => page.to_drop).should == "hello from title"}
  end

end
