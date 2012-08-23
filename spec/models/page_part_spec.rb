# encoding: UTF-8
require 'spec_helper'

describe PagePart do
  it { should be_a(PufferPages::Renderable) }

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:locale) }

    describe do
      before { Fabricate :page_part }
      it { should validate_uniqueness_of(:name).scoped_to(:page_id, :locale) }
    end
  end

  describe "default values" do
    before { I18n.stub(:default_locale).and_return(:cn) }
    specify { Fabricate(:page_part).locale.should == 'cn' }
  end

  describe "locale" do
    subject(:page_part) { Fabricate.build :page_part }

    context 'assigned a symbol' do
      before { page_part.locale = :ru }
      its(:locale) { should == 'ru' }
    end

    context 'assigned a string' do
      before { page_part.locale = 'ru' }
      its(:locale) { should == 'ru' }
    end

    context 'assigned nil' do
      before { page_part.locale = nil }
      its(:locale) { should be_nil }
    end
  end
end