# encoding: UTF-8
require 'spec_helper'

describe PagePart do
  it { should be_a(PufferPages::Renderable)}

  describe "validations" do
    it { should validate_presence_of(:name) }

    describe do
      before { Fabricate :page_part }
      it { should validate_uniqueness_of(:name).scoped_to(:page_id, :locale) }
    end
  end

  describe "default values" do
  	before { I18n.stub(:default_locale).and_return('cn'); }
  	specify { Fabricate(:page_part).locale.should == 'cn' }
  end
end