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

#            ActiveSupport::Deprecation.warn <<-DEPRECATE
#Layouts of type :puffer_pages or `puffer_pages` are deprecated.
#Please use `render :puffer_page => path_or_page_instance` or
#`puffer_pages` controller class method which acts similar to `layout`.
#            DEPRECATE

            options[:puffer_page] = options[:partial] if options[:partial].is_a?(::PufferPages::Page)
            options[:puffer_page] ||= _puffer_pages_template(options[:action].presence || options[:file])
            options[:layout] = 'puffer_pages'
          end
        end
      end
    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::ActionController::Base
