module PufferPages
  module Rspec
    module Matchers
      class RenderPage < ::RSpec::Matchers::BuiltIn::BaseMatcher
        attr_reader :scope, :page, :drops

        def initialize scope, page = nil
          @scope = scope
          @page = page
          @page = PufferPages::Page.find_page(page) if page.is_a?(String)
          @drops ||= { values: {}, names: [], manual: [] }
        end

        def matches? controller_or_request
          scope.get :index if controller_or_request.is_a?(ActionController::Base)

          rendered_page && (!with_page? || page_conformity) && (!with_drops? || drops_conformity)
        end

        def with_drops *drops, &block
          @drops[:values].merge! drops.extract_options!
          @drops[:names].concat(drops.flatten).uniq!
          @drops[:manual].push block if block
          self
        end

        def failure_message_for_should
          message = ''
          message << "expected action to render #{page_message}\n"
          message << "with drops #{drops_message}\n" if with_drops?
          if with_drops? && !drops_conformity
            rendered_drops = scope.puffer_pages_render[rendered_page].first[:drops]
            message << "but available drops are: #{PP.pp rendered_drops, ''}"
          else
            message << "but #{rendered_page ? "`/#{rendered_page.location}`" : 'nothing'} was rendered"
          end
          message
        end

        def failure_message_for_should_not
          "expected action not to render #{page_message} but `/#{rendered_page.location}` was rendered"
        end

        def description
          "render page #{page_message}"
        end

      private

        def page_message
          page ? "page `/#{page.location}`" : 'any page'
        end

        def drops_message
          [drops[:names], drops[:values]].delete_if(&:blank?).map(&:inspect).join ?,
        end

        def rendered_page
          @rendered_page ||= scope.puffer_pages_render.keys.first
        end

        def with_page?
          !!page
        end

        def page_conformity
          scope.puffer_pages_render[rendered_page] &&
          scope.puffer_pages_render[rendered_page].count == 1 &&
          rendered_page == page
        end

        def with_drops?
          drops.values.any?(&:present?)
        end

        def drops_conformity
          rendered_drops = scope.puffer_pages_render[rendered_page].first[:drops]

          rendered_drops.keys | drops[:names] == rendered_drops.keys &&
          drops[:values].all? { |(name, value)| rendered_drops[name] == value } &&
          drops[:manual].all? { |block| block.call(rendered_drops) }
        end
      end

      def render_page page = nil
        RenderPage.new self, page
      end
    end
  end
end