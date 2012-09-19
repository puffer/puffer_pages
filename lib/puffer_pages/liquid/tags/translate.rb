module PufferPages
  module Liquid
    module Tags

      class Translate < ::Liquid::Tag
        Syntax = /(#{QuotedFragment})\s+(#{QuotedFragment}+))?/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @key = $1
            @attributes    = {}

            markup.scan(TagAttributes) do |key, value|
              @attributes[key] = value
            end
          else
            raise SyntaxError.new("Error in tag 'include' - Valid syntax: translate key [option:value, option:value...]")
          end

          super
        end

        def parse(tokens)
        end

        def render(context)
          key = context[@key]
          attributes = {}
          @attributes.each do |key, value|
            attributes[key] = context[value]
          end

          if variable.is_a?(Array)
            variable.collect do |variable|
              context[@template_name[1..-2]] = variable
              partial.render(context)
            end
          else
            context[@template_name[1..-2]] = variable
            partial.render(context)
          end
        end

      end

    end
  end
end

Liquid::Template.register_tag('translate', PufferPages::Liquid::Tags::Translate)
Liquid::Template.register_tag('t', PufferPages::Liquid::Tags::Translate)