module PufferPages
  module Liquid
    class PageDrop < ::Liquid::Drop

      delegate *(PufferPages::Page.statuses.map {|s| "#{s}?"} << {:to => :page})
      delegate :id, :slug, :created_at, :updated_at, :to => :page

      def initialize page
        @page = page
      end

      def name
        @context ? page.render(page.name, @context) : page.name
      end

      %w(parent root ancestors self_and_ancestors children self_and_children siblings
         self_and_siblings descendants, self_and_descendants).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") ||
            instance_variable_set("@#{attribute}", page.send(attribute))
        end
      end

      def path
        controller.puffer_pages.puffer_page_path page.to_location
      end

      def url
        controller.puffer_pages.puffer_page_url page.to_location
      end

      def current?
        current_page && page == current_page
      end

      def ancestor?
        current_page && page.is_ancestor_of?(current_page)
      end

      def == other
        page == other.send(:page)
      end

      def before_method name
        page_part = page.inherited_page_part(name)
        page_part.handle(@context) if page_part && @context
      end

    private
      attr_reader :page

      def current_page
        @current_page ||= @context.registers[:page] if @context
      end

      def controller
        @controller ||= @context.registers[:controller] if @context
      end
    end
  end
end
