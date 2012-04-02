module PufferPages
  module Extensions
    module Renderer
      extend ActiveSupport::Concern

      included do
        alias_method_chain :render, :puffer_pages
      end

      def render_with_puffer_pages(context, options)
        if options[:puffer_page].present? && options[:puffer_page].is_a?(::PufferPages::Page)
          render_puffer_page(context, options)
        else
          render_without_puffer_pages(context, options)
        end
      end

      def render_puffer_page(context, options)
        _puffer_page_renderer.render(context, options)
      end

    private

      def _puffer_page_renderer #:nodoc:
        @_puffer_page_renderer ||= PufferPages::Renderer.new(@lookup_context)
      end
    end
  end
end

ActionView::Renderer.send :include, PufferPages::Extensions::Renderer