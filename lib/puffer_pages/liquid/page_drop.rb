module PufferPages
  module Liquid
    class PageDrop < ::Liquid::Drop

      include ActionController::UrlFor
      include Rails.application.routes.url_helpers

      def initialize page, request = nil, current_page = nil
        @page, @request, @current_page = page, request, current_page
      end

      (%w(name title description keywords created_at updated_at) + Page.statuses.map{|s| "#{s}?"}).each do |attribute|
        define_method attribute do
          page.send(attribute)
        end
      end

      def parent
        @parent ||= self.class.new(page.parent, @request, current_page)
      end

      %w(ancestors self_and_ancestors children self_and_children siblings self_and_siblings descendants, self_and_descendants).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", page.send(attribute).map{ |ac| self.class.new(ac, request, current_page)})
        end
      end

      def path
        puffer_page_path page.location
      end

      def url
        puffer_page_url page.location
      end

      def current?
        page == current_page
      end

      def ancestor?
        page.is_ancestor_of? current_page
      end

    private

      attr_reader :page, :request, :current_page

    end
  end
end
