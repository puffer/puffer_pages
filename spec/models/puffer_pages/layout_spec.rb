# encoding: UTF-8
require 'spec_helper'

describe PufferPages::Layout do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name)}
  end

  describe "#find_layout" do
    let!(:layout) { Fabricate :layout, :name => 'main' }

    specify { PufferPages::Layout.find_layout('main').should == layout}
  end
end
