module PufferPages
  module Extensions
    module ActionController
      module Base
        extend ActiveSupport::Concern

        included do
          helper_method :layout_page, :default_drops
        end

        def puffer_pages
          'puffer_pages_layout'
        end

        def layout_page
          @layout_page ||= ::Page.find_layout_page(@layout_path.presence || request.path_info)
        end

        def default_drops page
          {
            :self => PufferPages::Liquid::PageDrop.new(page, page, self),
            :root => PufferPages::Liquid::PageDrop.new(page.root, page, self)
          }.stringify_keys
        end
      end
    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::ActionController::Base
