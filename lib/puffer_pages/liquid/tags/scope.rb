module PufferPages
  module Liquid
    module Tags

      class Scope < ::Liquid::Block
        def initialize(tag_name, markup, tokens)
          @attributes = {}
          markup.scan(::Liquid::TagAttributes) do |key, value|
            @attributes[key] = value
          end

          super
        end

        def render(context)
          context.stack do
            @attributes.each do |key, value|
              context[key] = context[value]
            end

            super
          end
        end

        def blank?
          false
        end
      end

    end
  end
end

Liquid::Template.register_tag('scope', PufferPages::Liquid::Tags::Scope)
Liquid::Template.register_tag('context', PufferPages::Liquid::Tags::Scope)
