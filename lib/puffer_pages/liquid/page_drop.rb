module PufferPages
  module Liquid
    class PageDrop < ::Liquid::Drop

      include ActionController::UrlFor
      include Rails.application.routes.url_helpers

      delegate *(Page.statuses.map {|s| "#{s}?"} << {:to => :page})
      delegate :id, :created_at, :updated_at, :to => :page

      def initialize page, controller = nil
        @page, @controller = page, controller
      end

      %w(name title description keywords).each do |attribute|
        define_method attribute do
          value = page.send(attribute)
          value = ::Liquid::Template.parse(value).render(@context) if value.present? && @context
          value
        end
      end

      %w(parent root ancestors self_and_ancestors children self_and_children siblings
         self_and_siblings descendants, self_and_descendants).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") ||
            instance_variable_set("@#{attribute}", page.send(attribute).to_drop(controller))
        end
      end

      def path
        puffer_page_path page.to_location
      end

      def url
        puffer_page_url page.to_location
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

      def before_method method
        value = page.part(method)
        value.render(@context) if value && @context
      end

    private

      def current_page
        @current_page ||= @context.registers[:page] if @context
      end

      attr_reader :page, :controller
      delegate :env, :request, :to => :controller, :allow_nil => true

    end
  end
end
