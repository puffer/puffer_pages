require 'spec_helper'

describe 'Specs' do
  describe '#render_page' do
    include RSpec::Rails::ControllerExampleGroup

    let!(:layout) { Fabricate :application }
    let!(:root) { Fabricate :root }
    let!(:first) { Fabricate :page, slug: 'first', parent: root }
    let!(:second) { Fabricate :page, slug: 'second', parent: first }

    context 'no page specified' do
      context do
        controller do
          def index
            @page = PufferPages::Page.root
            render puffer_page: @page
          end
        end

        it { should render_page }
        specify do
          get :index
          response.should render_page
        end
      end

      context do
        controller do
          def index
            render nothing: true
          end
        end

        it { should_not render_page }
        specify do
          get :index
          response.should_not render_page
        end
      end
    end

    context 'with page instance' do
      controller do
        def index
          @page = PufferPages::Page.root
          render puffer_page: @page
        end

        def show
          @page = PufferPages::Page.find_page 'first'
          render puffer_page: @page
        end
      end

      it { should render_page root }
      it { should_not render_page first }
      it { should_not render_page second }
      specify do
        get :index
        response.should render_page root
      end
      specify do
        get :index
        response.should_not render_page first
      end
      specify do
        get :index
        response.should_not render_page second
      end
      specify do
        get :show, id: 42
        response.should_not render_page root
      end
      specify do
        get :show, id: 42
        response.should render_page first
      end
      specify do
        get :show, id: 42
        response.should_not render_page second
      end
    end

    context 'with drops' do
      controller do
        def index
          page = PufferPages::Page.root
          @count = 42
          @string = 'hello'
          @object = Object.new
          render puffer_page: page
        end
      end

      it { should render_page }
      it { should render_page.with_drops }
      it { should render_page.with_drops('count') }
      it { should render_page.with_drops('string' => 'hello') }
      it { should render_page.with_drops('string', 'count' => 42) }
      it { should render_page.with_drops { |drops| drops.keys.include?('string') } }
      it { should render_page.with_drops { |drops| drops['count'] > 40 } }
      it { should render_page.with_drops('count') { |drops| !drops.key?('object') } }
      it { should_not render_page.with_drops('object') }
    end
  end
end
