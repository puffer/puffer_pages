require 'spec_helper'

describe 'PufferPagesController' do
  let!(:layout) { Fabricate :application }
  let!(:root) { Fabricate :root }
  let!(:anonymous) { Fabricate :page, slug: 'anonymous', parent: root }
  let!(:first) { Fabricate :page, slug: 'first', parent: root }
  let!(:second) { Fabricate :page, slug: 'second', parent: first }
  let!(:third) { Fabricate :page, slug: 'third', parent: root, status: 'draft' }

  context '`:puffer_page` render option' do
    context do
      controller do
        def index
          render puffer_page: ''
        end
      end

      it { should render_page root }
    end

    context do
      controller do
        def index
          render puffer_page: '/'
        end
      end

      it { should render_page root }
    end

    context do
      controller do
        def index
          render puffer_page: 'first'
        end
      end

      it { should render_page first }
    end

    context do
      controller do
        def index
          render puffer_page: '/first'
        end
      end

      it { should render_page first }
    end

    context do
      controller do
        def index
          render puffer_page: '/first/second'
        end
      end

      it { should render_page second }
    end

    context do
      controller do
        def index
          @page = PufferPages::Page.find_page('first')
          render puffer_page: @page
        end
      end

      it { should render_page first }
    end

    context do
      controller do
        def index
          @page = PufferPages::Page.find_page('first/second')
          render @page
        end
      end

      specify { expect { get :index }.to raise_error(ActionView::MissingTemplate) }
    end
  end

  context '`puffer_pages` controller class method' do
    context do
      controller do
        puffer_pages

        def index
        end
      end

      it { should render_page root }
    end

    context do
      controller do
        puffer_pages

        def index
          render nothing: true
        end
      end

      it { should render_page root }
    end

    context do
      controller do
        puffer_pages except: :index

        def index
          render nothing: true
        end
      end

      it { should_not render_page }
    end

    context do
      controller do
        puffer_pages only: :show

        def index
          render nothing: true
        end
      end

      it { should_not render_page }
    end

    context do
      controller do
        puffer_pages

        def index
          render nothing: true, puffer_page: false
        end
      end

      it { should_not render_page }
    end

    context do
      controller do
        puffer_pages

        def index
          render puffer_page: 'first'
        end
      end

      it { should render_page first }
    end

    context do
      controller do
        puffer_pages

        def index
          render 'first/second'
        end
      end

      it { should render_page second }
    end

    context do
      controller do
        puffer_pages

        def index
          @page = PufferPages::Page.find_page('first')
          render @page
        end
      end

      it { should render_page first }
    end
  end

  context 'not existing pages' do
    context do
      controller do
        def index
          render puffer_page: 'third'
        end
      end

      context do
        render_views
        specify { expect { get :index }.to raise_error(PufferPages::DraftPage) }
      end

      context do
        it { should render_page 'third' }
      end
    end

    context do
      controller do
        def index
          render puffer_page: 'fourth'
        end
      end

      context do
        render_views
        specify { expect { get :index }.to raise_error(PufferPages::MissedPage) }
      end

      context do
        it { should render_page 'fourth' }
      end
    end
  end

  context 'controller assigns drops' do
    context do
      controller do
        def index
          @page = PufferPages::Page.root
          render puffer_page: @page
        end
      end

      it { should render_page.with_drops('self') }
    end

    context do
      controller do
        def index
          @count = 42
          @page = PufferPages::Page.root
          render puffer_page: @page
        end
      end

      it { should render_page.with_drops('count' => 42) }
    end
  end
end
