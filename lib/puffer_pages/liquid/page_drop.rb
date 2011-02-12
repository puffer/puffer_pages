module PufferPages
  module Liquid
    class PageDrop < ::Liquid::Drop

      def initialize page, request = nil
        @page, @request = page, request
      end

      (%w(name title description keywords created_at updated_at) + Page.statuses.map{|s| "#{s}?"}).each do |attribute|
        define_method attribute do
          @page.send(attribute)
        end
      end

      def parent
        @parent ||= self.class.new(@page.parent, @request)
      end

      %w(children ancestors).each do |attribute|
        define_method attribute do
          instance_variable_get("@#{attribute}") || instance_variable_set("@#{attribute}", @page.send(attribute).map{ |page| self.class.new(page, @request)})
        end
      end

      def ancestors?
        !@page.root?
      end

      def children?
        @page.children.present?
      end

      def path
        
      end

      def url
        
      end

    end
  end
end
