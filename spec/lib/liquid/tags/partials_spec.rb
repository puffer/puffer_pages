require 'spec_helper'

describe PufferPages::Liquid::Tags::Partials do
  describe 'snippet' do
    let!(:root) { Fabricate :root }
    let!(:custom) { Fabricate :custom }

    specify { root.render("{% snippet 'custom' %}").should == custom.body }
    specify { root.render("{% assign snippet = 'custom' %}{% snippet snippet %}").should == custom.body }

    context do
      let!(:custom) { Fabricate :custom, body: "{{ custom }}" }
      specify { root.render("{% snippet 'custom' with 'hello' %}").should == 'hello' }
    end

    context do
      let!(:custom) { Fabricate :custom, body: "{{ variable }}" }
      specify { root.render("{% snippet 'custom', variable: 'hello' %}").should == 'hello' }
    end
  end

  describe 'layout' do
    let!(:root) { Fabricate :root }
    let!(:application) { Fabricate :application }

    specify { root.render("{% layout 'application' %}").should == application.body }
    specify { root.render("{% assign layout = 'application' %}{% layout layout %}").should == application.body }

    context do
      let!(:application) { Fabricate :application, body: "{{ application }}" }
      specify { root.render("{% layout 'application' with 'hello' %}").should == 'hello' }
    end

    context do
      let!(:application) { Fabricate :application, body: "{{ variable }}" }
      specify { root.render("{% layout 'application', variable: 'hello' %}").should == 'hello' }
    end
  end
end
