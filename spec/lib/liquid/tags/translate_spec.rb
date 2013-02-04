require 'spec_helper'

describe PufferPages::Liquid::Tags::Translate do

  def render_page(page, drops = {})
    page.render({ self: page }.merge(drops))
  end

  before do
    @backend = I18n.backend
    I18n.backend = I18n::Backend::Simple.new
  end
  after do
    I18n.backend = @backend
  end

  context '#i18n_defaults and #i18n_scope' do
    let!(:root) { Fabricate :root }
    let!(:foo) { Fabricate :page, slug: 'foo', parent_id: root.id }
    let!(:bar) { Fabricate :page, slug: 'bar', parent_id: foo.id }
    let!(:main) { Fabricate :main, page_id: root.id }
    let!(:foo_main) { Fabricate :main, page_id: foo.id }
    let!(:bar_main) { Fabricate :main, page_id: bar.id }
    let!(:layout) { Fabricate :application }
    let!(:snippet) { Fabricate :custom }

    specify { main.i18n_scope.should == [:pages, :page_parts, :body] }
    specify { main.i18n_defaults.should == [[:pages, :page_parts, :body], [:pages]] }
    specify { foo_main.i18n_scope.should == [:pages, :foo, :page_parts, :body] }
    specify { foo_main.i18n_defaults.should == [[:pages, :foo, :page_parts, :body], [:pages, :foo],
      [:pages, :page_parts, :body], [:pages]] }
    specify { bar_main.i18n_scope.should == [:pages, :foo, :bar, :page_parts, :body] }
    specify { bar_main.i18n_defaults.should == [[:pages, :foo, :bar, :page_parts, :body], [:pages, :foo, :bar],
      [:pages, :foo, :page_parts, :body], [:pages, :foo], [:pages, :page_parts, :body], [:pages]] }

    specify { layout.i18n_scope.should == [:layouts, :application] }
    specify { layout.i18n_defaults.should == [] }

    specify { snippet.i18n_scope.should == [:snippets, :custom] }
    specify { snippet.i18n_defaults.should == [] }
  end

  context 'layouts' do
    let!(:root) { Fabricate :root }

    context 'partial' do
      before { I18n.backend.store_translations(:en, layouts: { application: { hello: 'I18n partial hello' } }) }
      let!(:layout) { Fabricate :application, body: "{% t '.hello' %}" }
      specify { root.render.should == 'I18n partial hello' }
    end

    context 'full' do
      before { I18n.backend.store_translations(:en, world: { hello: 'I18n full hello' }) }
      let!(:layout) { Fabricate :application, body: "{% t 'world.hello' %}" }
      specify { root.render.should == 'I18n full hello' }
    end
  end

  context 'snippets' do
    let!(:root) { Fabricate :root }
    let!(:layout) { Fabricate :application, body: "{% snippet 'custom' %}" }

    context 'partial' do
      before { I18n.backend.store_translations(:en, snippets: { custom: { hello: 'I18n partial hello' } }) }
      let!(:snippet) { Fabricate :custom, body: "{% t '.hello' %}" }
      specify { root.render.should == 'I18n partial hello' }
    end

    context 'full' do
      before { I18n.backend.store_translations(:en, world: { hello: 'I18n full hello' }) }
      let!(:snippet) { Fabricate :custom, body: "{% t 'world.hello' %}" }
      specify { root.render.should == 'I18n full hello' }
    end
  end

  context 'root page_parts' do
    let!(:root) { Fabricate :root }
    let!(:layout) { Fabricate :application, body: "{% include 'body' %}" }

    context 'partial fallback' do
      before { I18n.backend.store_translations(:en, pages: { hello: 'I18n partial hello fallback' }) }
      let!(:main) { Fabricate :main, body: "{% t '.hello' %}", page_id: root.id }
      specify { root.render.should == 'I18n partial hello fallback' }
    end

    context 'partial' do
      before { I18n.backend.store_translations(:en, pages: { page_parts: { body: { hello: 'I18n partial hello' } } }) }
      let!(:main) { Fabricate :main, body: "{% t '.hello' %}", page_id: root.id }
      specify { root.render.should == 'I18n partial hello' }
    end

    context 'full' do
      before { I18n.backend.store_translations(:en, world: { hello: 'I18n full hello' }) }
      let!(:main) { Fabricate :main, body: "{% t 'world.hello' %}", page_id: root.id }
      specify { root.render.should == 'I18n full hello' }
    end
  end

  context 'options' do
    let!(:root) { Fabricate :root }
    let!(:layout) { Fabricate :application, body: "{% t '.hello' param: 'hello' %}" }
    before { I18n.backend.store_translations(:en, layouts: { application: { hello: 'some params %{param}' } }) }

    specify { root.render.should == 'some params hello' }
  end

end
