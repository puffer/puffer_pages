module PufferPages
  module Extensions
    module ActionController
      module Base
        extend ActiveSupport::Concern

        included do
          helper_method :layout_page, :layout_page_drops
        end

        module InstanceMethods
          def puffer_pages
            'puffer_pages_layout'
          end

          def layout_page
            @layout_page ||= ::Page.find_layout_page(request.path_info)
          end

          def layout_page_drops
            {
              :self => PufferPages::Liquid::PageDrop.new(layout_page, layout_page, self),
              :root => PufferPages::Liquid::PageDrop.new(layout_page.root, layout_page, self)
            }.merge(@drops.presence || {}).stringify_keys
          end

        end

      end
    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::ActionController::Base
