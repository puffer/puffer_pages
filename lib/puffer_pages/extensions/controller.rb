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

          if options[:text].blank? && options[:inline].blank? &&
             (possible_layout.is_a?(Proc) ? possible_layout.call : possible_layout) =~ /puffer_pages$/
            options[:puffer_page] = options.delete(:partial) if options[:partial].is_a?(::PufferPages::Page)
            options[:puffer_page] ||= _puffer_pages_template(options[:action].presence || options[:file])
            options[:layout] = possible_layout
          end

          options[:puffer_page] = _puffer_pages_template(options[:puffer_page]) if options[:puffer_page].present? && !options[:puffer_page].is_a?(::PufferPages::Page)
        end

      private

        def _puffer_pages_template suggest
          ::Page.find_layout_page(suggest.presence || request.path_info)
        end
      end
    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::ActionController::Base
