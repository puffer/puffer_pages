module PufferPages
  module Liquid
    class Backend
      include ::I18n::Backend::Simple::Implementation

      def load_translations; end
      def store_translations(*args); end
      def initialized?; true; end

      def translations
        Contextuality.page_translations || {}
      end

    end
  end
end
