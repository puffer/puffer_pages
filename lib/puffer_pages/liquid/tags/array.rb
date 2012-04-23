module PufferPages
  module Liquid
    module Tags

      class Array < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @items = variables_from_string(markup)
            @variable_name = @items.shift
          else
            raise SyntaxError.new("Syntax Error in 'array' - Valid syntax: array array_name [, item, item ...]")
          end

          super
        end

        def render(context)
          context[context[@variable_name].to_s] = @items.map { |item| context[item] }
          ''
        end

      private

        def variables_from_string(markup)
          markup.split(',').map do |var|
            var.strip =~ /\s*(#{::Liquid::QuotedFragment})\s*/
            $1 ? $1 : nil
          end.compact
        end

      end

    end
  end
end

Liquid::Template.register_tag('array', PufferPages::Liquid::Tags::Array)
