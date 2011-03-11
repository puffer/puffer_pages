require 'spec_helper'

describe Page do

  it 'should have only one root' do
    @root = Fabricate :page, :layout_name => 'foo_layout'
    @root2 = Fabricate :page, :layout_name => 'foo_layout'

    Page.roots.should == [@root]
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
      @baz = Fabricate :page, :slug => 'foo', :parent => @root
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

    it 'should create default `main` part for root page' do
      @root.page_parts.map(&:name).should == [PufferPages.primary_page_part_name]
    end

    it 'should receive proper inherited page parts' do
      @root.inherited_page_parts.map(&:body).should == [nil]
      @foo.inherited_page_parts.map(&:body).should == [nil, '2']
      @bar.inherited_page_parts.map(&:body).should == ['4', '2']
      @baz.inherited_page_parts.map(&:body).should == ['4', '3', '5']
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
      @root.render_layout.should == 'foo_layout'
      @foo.render_layout.should == 'foo_layout'
      @bar.render_layout.should == false
      @baz.render_layout.should == false
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
      result.should == "#{@root.title}<% content_for :sidebar do %>#{@root.name}<% end %>"
    end

    it 'should render layout' do
      @layout = Fabricate :layout, :name => 'foo_layout', :body => "{% include 'body' %} {% include 'sidebar' %}"
      result = @root.render 'self' => PufferPages::Liquid::PageDrop.new(@root)
      result.should == "#{@root.title} #{@root.name}"
    end

    it 'should receive proper content type' do
      @root.content_type.should == 'text/html'
      page = Fabricate :page, :slug => 'style.css'
      page.content_type.should == 'text/css'
    end

  end

end
