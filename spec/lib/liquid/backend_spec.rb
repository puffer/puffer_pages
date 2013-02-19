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

  context 'backend installation' do
    context 'fallbacks' do
      specify do
        contextualize(page_translations: translations) do
          I18n.with_locale :ru do
            I18n.translate('hello')
          end
        end.should == 'PufferPages world'
      end
    end
  end
end
