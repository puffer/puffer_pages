module PufferPages
  module Liquid
    module Tags

      class Array < ::Liquid::Tag
        Syntax = /^(#{::Liquid::VariableSignature}+)\s*=\s*(.*)\s*/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @variable_name = $1
            @items = variables_from_string($2)
          else
            raise SyntaxError.new("Syntax Error in 'array' - Valid syntax: array array_name = item[, item ...]")
          end

          super
        end

        def render(context)
          context[@variable_name] = @items.map { |item| context[item] }
          ''
        end

        def blank?
          false
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
