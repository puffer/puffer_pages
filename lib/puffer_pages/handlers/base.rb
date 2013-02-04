module PufferPages
  module Handlers
    class Base
      attr_reader :type

      def initialize type
        @type = type
      end

      def process renderable, context = nil
        renderable.render context
      end

      def codemirror_mode
        'text/x-liquid-html'
      end
    end
  end
end

PufferPages::Handlers.register PufferPages::Handlers::Base, :html
