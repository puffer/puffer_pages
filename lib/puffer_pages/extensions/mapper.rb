module PufferPages
  module Extensions
    module Mapper
      extend ActiveSupport::Concern

      included do
        class_attribute :_puffer_pages
      end

      module InstanceMethods

        def puffer_pages_options
          self.class._puffer_pages.presence || [{'(*path)' => 'pages#index', :as => 'puffer_page'}]
        end

        def puffer_pages *args
          options = args.extract_options!
          options.merge! :as => 'puffer_page'
          self.class._puffer_pages = args.push(options)
        end

      end

    end

  end
end

ActionDispatch::Routing::Mapper.send :include, PufferPages::Extensions::Mapper
