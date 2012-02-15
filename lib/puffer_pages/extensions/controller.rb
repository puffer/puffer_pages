module PufferPages
  module Extensions
    module ActionController
      module Base
        extend ActiveSupport::Concern

        def puffer_pages
          'puffer_pages'
        end

        def _normalize_options(options)
          super

          layout_name = options.key?(:layout) ? options[:layout] : :default
          possible_layout = _layout_for_option(layout_name)

          if (possible_layout.is_a?(Proc) ? possible_layout.call : possible_layout) == 'layouts/puffer_pages'
            options[:puffer_pages] = true
            options[:layout] = possible_layout
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::ActionController::Base
