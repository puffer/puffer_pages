module PufferPages
  module Liquid
    class PageDrop < ::Liquid::Drop

      include ActionController::UrlFor
      include Rails.application.routes.url_helpers

      def initialize page, request = nil
        @page, @request = page, request
      end

      (%w(name title description keywords created_at updated_at) + Page.statuses.map{|s| "#{s}?"}).each do |attribute|
        define_method attribute do
          page.send(attribute)
        end
      end

      def parent
        @parent ||= self.class.new(page.parent, @request)
      end

      %w(ancestors children).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", page.send(attribute).map{ |ac| self.class.new(ac, request)})
        end
      end

      def ancestors?
        !page.root?
      end

      def children?
        page.children.present?
      end

      def path
        puffer_page_path page.location
      end

      def url
        puffer_page_url page.location
      end

      def current?
        path == request.path_info
      end

      def ancestor?
        request.path_info.start_with? path
      end

    private

      def request
        @request
      end

      def page
        @page
      end

    end
  end
end
