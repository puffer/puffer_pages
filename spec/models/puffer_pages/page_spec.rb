# encoding: UTF-8
require 'spec_helper'

describe PufferPages::Page do
  it { should be_a(PufferPages::Backends::Mixins::Renderable) }

  describe '.normalize_path' do
    specify{PufferPages::Page.normalize_path(nil).should == nil}
    specify{PufferPages::Page.normalize_path('').should == nil}
    specify{PufferPages::Page.normalize_path('/').should == nil}
    specify{PufferPages::Page.normalize_path('hello').should == 'hello'}
    specify{PufferPages::Page.normalize_path('hello/world').should == 'hello/world'}
    specify{PufferPages::Page.normalize_path('/hello///world//').should == 'hello/world'}
  end

  describe 'attributes' do

    before { @root = Fabricate :page, :layout_name => 'foo_layout' }

    it 'has nil slug location if root' do
      @root.slug.should == nil
      @root.location.should == nil
    end

    it 'generates proper location' do
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'bar', :parent => @foo
      @baz = Fabricate :page, :slug => 'baz', :parent => @bar
      @foo.location.should == 'foo'
      @bar.location.should == 'foo/bar'
      @baz.location.should == 'foo/bar/baz'
    end

    it 'checks slug uniqueness' do
      @foo = Fabricate :page, :slug => 'foo', :parent => @root
      @bar = Fabricate :page, :slug => 'foo', :parent => @foo
      @baz = Fabricate.build :page, :slug => 'foo', :parent => @root
      @foo.should be_valid
      @bar.should be_valid
      @baz.should_not be_valid
    end

    it 'updates descendants locations' do
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
      @body = @root.page_parts.create :name => "body"
      @foo = Fabricate :page, :slug => 'foo', :parent => @root

      @bar = Fabricate :page, :slug => 'bar', :parent => @foo,
        :page_parts => [Fabricate(:page_part, :name => PufferPages.primary_page_part_name, :body => '4')]

      @baz = Fabricate :page, :slug => 'baz',
        :parent => @bar, :page_parts => [
          Fabricate(:page_part, :name => 'sidebar', :body => '5'),
          Fabricate(:page_part, :name => 'additional', :body => '3')
        ]
      @foo.page_parts = [Fabricate(:page_part, :name => 'sidebar', :body => '2')]
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
    context 'when localization is off' do
      before { PufferPages.stub(:localize).and_return(false) }

      let!(:main_part) { Fabricate :main }
      let!(:sidebar_part) { Fabricate :sidebar }
      let!(:page) { Fabricate :root, page_parts: [main_part, sidebar_part] }

      context "default locale is English" do
        before { I18n.stub(:default_locale).and_return(:en) }

        it 'should render content_for blocks if rails layout used' do
          result = page.render 'self' => PufferPages::Liquid::PageDrop.new(page)
          result.should == "PagePart: `body`, Page: ``<% content_for :'sidebar' do %>PagePart: `sidebar`, Page: ``<% end %>"
        end

        it 'should render layout' do
          @layout = Fabricate :application, body: "{% include 'body' %} {% include 'sidebar' %}"
          result = page.render 'self' => PufferPages::Liquid::PageDrop.new(page)
          result.should == "PagePart: `body`, Page: `` PagePart: `sidebar`, Page: ``"
        end

        it 'should receive proper content type' do
          page.content_type.should == 'text/html'
          child_page = Fabricate :page, :slug => 'style.css', :parent => page
          child_page.content_type.should == 'text/css'
        end
      end
    end

    if PufferPages.localize
      context 'when localization is on' do
        before { I18n.stub(:default_locale).and_return(:en) }
        before { PufferPages.stub(:localize).and_return(true) }

        let!(:main_part) { Fabricate :main, body_translations: { en: 'En-body', ru: 'Ru-body' } }
        let!(:sidebar_part) { Fabricate :sidebar, body_translations: { en: 'En-sidebar' } }
        let!(:page) { Fabricate :root, page_parts: [main_part, sidebar_part] }

        context 'and current language is English' do
          before { I18n.stub(:locale).and_return(:en) }

          it 'should render content_for blocks if rails layout used' do
            result = page.render self: page
            result.should == "En-body<% content_for :'sidebar' do %>En-sidebar<% end %>"
          end

          it 'should render layout' do
            @layout = Fabricate :application, body: "{% include 'body' %} {% include 'sidebar' %}"
            result = page.render self: page
            result.should == "En-body En-sidebar"
          end
        end

        context 'and current language is Russian' do
          before { I18n.stub(:locale).and_return(:ru) }

          it 'should render content_for blocks if rails layout used and fallback to the default locale for missing parts' do
            result = page.render self: page
            result.should == "Ru-body<% content_for :'sidebar' do %>En-sidebar<% end %>"
          end

          it 'should render layout and fallback to the default locale for missing parts' do
            @layout = Fabricate :application, body: "{% include 'body' %} {% include 'sidebar' %}"
            result = page.render self: page
            result.should == "Ru-body En-sidebar"
          end
        end
      end
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
      PufferPages::Page.find_page(nil).should == @root
    end

    it 'not root page' do
      PufferPages::Page.find_page('foo/bar').should == @bar
    end

    it 'not existent page' do
      expect {PufferPages::Page.find_page('foo/baz') }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'draft page' do
      expect {PufferPages::Page.find_page('foo/bar/baz') }.to raise_error(PufferPages::DraftPage)
    end

    it 'single section root page' do
      single_section_page_path do
        PufferPages::Page.find_page(nil).should == @root
      end
    end

    it 'single section not root page' do
      single_section_page_path do
        PufferPages::Page.find_page('foo').should == @foo
        PufferPages::Page.find_page('bar').should == @bar
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
      PufferPages::Page.find_view_page('/').should == @root
    end

    it 'not root page' do
      PufferPages::Page.find_view_page('/foo').should == @foo
      PufferPages::Page.find_view_page('/foo/bar').should == @bar
      PufferPages::Page.find_view_page('/foo/baz').should == @bar
      PufferPages::Page.find_view_page('/foo/bar/baz').should == @baz
      PufferPages::Page.find_view_page('/foo/moo/baz').should == @baz
    end

    it 'not existent page' do
      expect {PufferPages::Page.find_view_page('/bar')}.to raise_error(PufferPages::LayoutMissed)
    end

    it 'draft page' do
      @bar.update_attributes(:status => 'draft')
      expect {PufferPages::Page.find_view_page('/foo/bar')}.to raise_error(PufferPages::LayoutMissed)
    end

    it "should choose the last created (with the most right tree location) page from those fitting the requested path and format" do
      PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:html]).should == @baz
    end
    it "should use %-ending locations for html requests with the same priority as locations without % end
        (so in this case the priority is regulated only by tree location)" do
      PufferPages::Page.find_view_page('/foo/moo/quux', :formats => [:html]).should == @qux
    end
    specify {PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:html, :js]).should == @baz}
    specify {PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:js]).should == @bazjs}
    specify {PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:js, :html]).should == @bazjs}
    specify {PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:xml, :html]).should == @baz}
    specify {PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:xml, :js]).should == @bazjs}
    it "should not use %-ending locations for formats other than html, thus generating an error if format is different" do
      expect {PufferPages::Page.find_view_page('/foo/moo/baz', :formats => [:xml])}.to raise_error(PufferPages::LayoutMissed)
    end

  end

  context 'renderable attributes' do
    let!(:page) { Fabricate(:root, :name => "{{ page.body }}", :page_parts => [Fabricate(:main)] ) }

    specify { page.render.should == "PagePart: `body`, Page: ``"}
  end

  context 'i18n translations' do
    let(:translations) { { en: YAML.dump(hello: 'Hello', additional: 'Test'), de: YAML.dump(hello: 'Hallo') } }
    let(:translations_update) { { en: YAML.dump(hello: 'Bye'), de: YAML.dump(hello: 'Chao') } }

    let!(:root) { Fabricate :root, locales: translations }
    let!(:first) { Fabricate :root, slug: 'first', parent: root, locales: translations_update }

    describe '#page_translations' do
      specify do
        root.page_translations.should == {
          en: { hello: 'Hello', additional: 'Test' },
          de: { hello: 'Hallo' }
        }
      end
      specify do
        first.page_translations.should == {
          en: { hello: 'Bye', additional: 'Test' },
          de: { hello: 'Chao' }
        }
      end
    end
  end

end
