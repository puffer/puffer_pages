require 'spec_helper'

describe PagesController do

  before { @routes = PufferPages::Engine.routes }

  describe "GET index" do
    render_views

    let!(:layout) { Fabricate :application }
    let!(:root) { Fabricate :root }
    let!(:first) { Fabricate :page, slug: 'first', parent: root }
    let!(:second) { Fabricate :page, slug: 'second.css', parent: first }

    describe "proper page rendering" do
      it { should render_page root }
      specify do
        get :index, path: 'first'
        response.should render_page first
        response.should be_ok
      end
      specify do
        get :index, path: 'first/second.css'
        response.should render_page second
        response.content_type.should == 'text/css'
        response.should be_ok
      end
      specify do
        expect { get :index, path: 'first/second' }.to raise_error PufferPages::MissedPage
        response.should_not render_page
        response.should_not be_not_found
      end
    end

    describe "layout loaded from filesystem" do
      let!(:root) { Fabricate :root, layout_name: 'sample' }

      context do
        specify do
          get :index
          response.should render_template 'layouts/sample'
        end
      end
    end
  end
end
