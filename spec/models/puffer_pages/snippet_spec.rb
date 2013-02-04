# encoding: UTF-8
require 'spec_helper'

describe PufferPages::Snippet do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

  describe "#find_snippet" do
    let!(:snippet) { Fabricate :snippet, :name => 'main' }

    specify { PufferPages::Snippet.find_snippet('main').should == snippet}
  end
end
