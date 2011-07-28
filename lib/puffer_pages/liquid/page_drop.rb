module PufferPages
  module Liquid
    class PageDrop < ::Liquid::Drop

      include ActionController::UrlFor
      include Rails.application.routes.url_helpers

      delegate *(Page.statuses.map {|s| "#{s}?"} << {:to => :page})
      delegate :name, :title, :description, :keywords, :created_at, :updated_at, :to => :page

      def initialize page, current_page = nil, controller = nil
        @page, @current_page, @controller = page, current_page, controller
      end

      %w(parent root).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", self.class.new(page.parent, current_page, request))
        end
      end

      %w(ancestors self_and_ancestors children self_and_children siblings self_and_siblings descendants, self_and_descendants).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", page.send(attribute).map{ |ac| self.class.new(ac, current_page, request)})
        end
      end

      def path
        puffer_page_path page.to_location
      end

      def url
        puffer_page_url page.to_location
      end

      def current?
        page == current_page
      end

      def ancestor?
        page.is_ancestor_of? current_page
      end

      def == drop
        page.id == drop.send(:page).id
      end

      def before_method method
        swallow_nil{page.part(method).body}
      end

    private

      attr_reader :page, :current_page, :controller
      delegate :env, :request, :to => :controller, :allow_nil => true

    end
  end
end
