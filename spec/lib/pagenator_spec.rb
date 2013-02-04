require 'spec_helper'

describe PufferPages::Extensions::Pagenator do
  context 'controller' do
    include RSpec::Rails::ControllerExampleGroup
    let!(:foo_layout){Fabricate :foo_layout}
    let!(:root){Fabricate :foo_root}
    let!(:anonymous){Fabricate :page, :slug => 'anonymous', :name => 'foo', :parent => root}
    let!(:foo){Fabricate :page, :slug => 'foo', :parent => root}
    let!(:bar){Fabricate :page, :slug => 'bar', :parent => foo}

    let!(:bar_layout){Fabricate :bar_layout}
    let!(:root2){Fabricate :foo_root, :layout_name => 'bar_layout'}

    let!(:named){Fabricate :page, :slug => 'named', :name => 'foo', :parent => root}
    let!(:named2){Fabricate :page, :slug => 'named', :name => 'bar', :parent => root2}

    context do
      controller do
        puffer_pages
        def index; end
      end

      specify do
        get :index
        response.body.should == 'foo_layout anonymous'
      end
    end

    context do
      controller do
        puffer_pages :only => :index
        def index; end
      end

      specify do
        get :index
        response.body.should == 'foo_layout anonymous'
      end
    end

    context do
      controller do
        puffer_pages :except => :show
        def index; end
      end

      specify do
        get :index
        response.body.should == 'foo_layout anonymous'
      end
    end

    context do
      controller do
        puffer_pages :only => [:show]
        def index; end
      end

      specify{expect{get :index}.to raise_error}
    end

    context do
      controller do
        puffer_pages :except => [:index]
        def index; end
      end

      specify{expect{get :index}.to raise_error}
    end

    context do
      controller do
        puffer_pages
        def index
          render 'foo'
        end
      end

      specify do
        get :index
        response.body.should == 'foo_layout foo'
      end
    end

    context do
      controller do
        puffer_pages
        def index
          render PufferPages::Page.where(:slug => 'foo').first
        end
      end

      specify do
        get :index
        response.body.should == 'foo_layout foo'
      end
    end

    context do
      controller do
        puffer_pages
        def index
          render 'foo/bar'
        end
      end

      specify do
        get :index
        response.body.should == 'foo_layout bar'
      end
    end

    context do
      controller do
        puffer_pages
        def index
          render 'foo/bar'
        end
      end

      specify do
        get :index
        response.body.should == 'foo_layout bar'
      end
    end

    context do
      controller do
        puffer_pages :scope => {:name => 'foo'}
        def index
          render 'named'
        end
      end

      specify do
        get :index
        response.body.should == 'foo_layout named'
      end
    end

    context do
      controller do
        puffer_pages :scope => lambda {|conroller|
          {:name => 'bar'}
        }
        def index
          render 'named'
        end
      end

      specify do
        get :index
        response.body.should == 'bar_layout named'
      end
    end

    context do
      controller do
        puffer_pages :scope => :puffer_scope
        def index
          render 'named'
        end

        def puffer_scope
          {:name => 'bar'}
        end
      end

      specify do
        get :index
        response.body.should == 'bar_layout named'
      end
    end
  end
end