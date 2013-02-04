require 'spec_helper'

describe PufferPages::Liquid::Backend do
  let(:backend) { described_class.new }
  let(:translations) { { en: { hello: 'PufferPages world' } } }

  specify { backend.translations == {} }

  specify do
    contextualize(page_translations: translations) do
      backend.translations
    end.should == translations
  end

  specify do
    contextualize(page_translations: translations) do
      backend.translate(:en, 'hello')
    end.should == 'PufferPages world'
  end
end
