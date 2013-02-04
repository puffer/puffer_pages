module PufferPages
  module Handlers
    class Yaml < Base
      def process renderable, context = nil
        renderable.self_and_ancestors.where(handler: 'yaml').reverse.each_with_object({}) do |renderable, result|
          load_arguments = [renderable.render(context)]
          load_arguments.push renderable.name if YAML.method(:load).arity == -2
          hash = YAML.load *load_arguments
          result.deep_merge! hash
        end
      end

      def codemirror_mode
        'text/x-liquid-yaml'
      end
    end
  end
end

PufferPages::Handlers.register PufferPages::Handlers::Yaml, :yaml
