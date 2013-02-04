# encoding: UTF-8
require 'spec_helper'

describe PufferPages::PagePart do
  it { should be_a(PufferPages::Backends::Mixins::Renderable) }

  describe "validations" do
    it { should validate_presence_of(:name) }

    describe do
      it { should validate_uniqueness_of(:name) }
    end
  end
end
