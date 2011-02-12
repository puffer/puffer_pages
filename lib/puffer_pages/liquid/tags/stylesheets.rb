module PufferPages
  module Liquid
    module Tags

      class Stylesheets < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @paths = variables_from_string(markup)
          else
            raise SyntaxError.new("Syntax Error in 'stylesheets' - Valid syntax: stylesheets path [, path, path ...]")
          end

          super
        end

        def render(context)
          paths = @paths.map {|path| "'#{context[path]}'" }.join(', ')
          context.registers[:tracker].register "<%= stylesheet_link_tag #{paths} %>"
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

Liquid::Template.register_tag('stylesheets', PufferPages::Liquid::Tags::Stylesheets)
