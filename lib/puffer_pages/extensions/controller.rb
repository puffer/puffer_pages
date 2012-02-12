module PufferPages
  module Extensions
    module ActionController
      module Base
        extend ActiveSupport::Concern

        def puffer_pages
          'puffer_pages'
        end
      end
    end
  end
end

ActionController::Base.send :include, PufferPages::Extensions::ActionController::Base
