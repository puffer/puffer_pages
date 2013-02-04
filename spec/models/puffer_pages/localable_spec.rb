# encoding: UTF-8
require 'spec_helper'

describe PufferPages::Backends::Mixins::Localable do
  let(:locales_class) { PufferPages::Backends::Mixins::Localable::Locales }

  context do
    let!(:page) { Fabricate.build :root }
    specify { page.locales.should == {} }
    specify { page.locales.should be_a locales_class }
  end

  context do
    let!(:page) { Fabricate :root }
    specify { page.locales.should == {} }
    specify { page.reload.locales.should == {} }
    specify { page.locales.should be_a locales_class }
    specify { page.reload.locales.should be_a locales_class }
  end

  context do
    let!(:page) { Fabricate :root, locales: { en: 'hello: world' } }
    specify { page.locales.should == { 'en' => 'hello: world' } }
    specify { page.reload.locales.should == { 'en' => 'hello: world' } }
    specify { page.locales.should be_a locales_class }
    specify { page.reload.locales.should be_a locales_class }
  end

  context do
    let!(:page) { Fabricate.build :root, locales: { en: 'Hello' } }
    specify { page.should be_invalid }
    specify { page.tap { |page| page.valid? }.errors[:locales].first.should == page.locales.error }
  end
end

describe PufferPages::Backends::Mixins::Localable::Locales do
  let(:valid) {
    described_class.new(
      en: YAML.dump(hello: 'World', bye: 'Hell'),
      de: YAML.dump('key' => 'value')
    )
  }
  let(:invalid) {
    described_class.new(
      en: YAML.dump('hello')
    )
  }
  describe '#translations' do
    specify { valid.translations.should == { en: { hello: 'World', bye: 'Hell' }, de: { key: 'value' } } }
    specify { expect { invalid.translations }.to raise_exception SyntaxError }
  end

  describe '#valid?' do
    specify { valid.should be_valid }
    specify { invalid.should_not be_valid }
  end

  describe '#valid?' do
    specify { valid.error.should be_false }
    specify { invalid.error.should =~ /Locale should be a hash/ }
  end
end
