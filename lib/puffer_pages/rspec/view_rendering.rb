module PufferPages
  module Rspec
    module ViewRendering
      extend ActiveSupport::Concern

      included do
        before do
          unless render_views?
            dummy_page = PufferPages::Page.new
            dummy_page.stub(:inherited_layout) { '' }
            dummy_page.stub(:dummy_page?) { true }
            controller.stub(:_puffer_page_for) do |location, scope|
              dummy_page.stub(:location) { PufferPages::Page::normalize_path(location) }
              dummy_page
            end
          end
        end
      end
    end
  end
end
