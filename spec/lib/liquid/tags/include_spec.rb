require 'spec_helper'

describe PufferPages::Liquid::Tags::Include do
  describe 'include page_part' do
    let!(:root) { Fabricate :root, page_parts: [main, sidebar] }
    let!(:main) { Fabricate :main }
    let!(:sidebar) { Fabricate :sidebar }

    specify { root.render("{% include '#{PufferPages.primary_page_part_name}' %}").should == main.body }
    specify { root.render("{% assign sb = 'sidebar' %}{% include sb %}").should == sidebar.body }
  end

  describe 'include snippet' do
    let!(:root) { Fabricate :root }
    let!(:custom) { Fabricate :custom }

    specify { root.render("{% include 'snippets/custom' %}").should == custom.body }
    specify { root.render("{% assign snippet = 'snippets/custom' %}{% include snippet %}").should == custom.body }

    context do
      let!(:custom) { Fabricate :custom, body: "{{ variable }}" }
      specify { root.render("{% include 'snippets/custom', variable: 'hello' %}").should == 'hello' }
    end
  end

  describe 'include layout' do
    let!(:root) { Fabricate :root }
    let!(:application) { Fabricate :application }

    specify { root.render("{% include 'layouts/application' %}").should == application.body }
    specify { root.render("{% assign layout = 'layouts/application' %}{% include layout %}").should == application.body }

    context do
      let!(:application) { Fabricate :application, body: "{{ variable }}" }
      specify { root.render("{% include 'layouts/application', variable: 'hello' %}").should == 'hello' }
    end
  end
end
