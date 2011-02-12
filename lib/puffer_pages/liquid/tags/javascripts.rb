module PufferPages
  module Liquid
    module Tags

      class Javascripts < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @paths = variables_from_string(markup)
          else
            raise SyntaxError.new("Syntax Error in 'javascripts' - Valid syntax: javascripts path [, path, path ...]")
          end

          super
        end

        def render(context)
          paths = @paths.map {|path| "'#{context[path]}'" }.join(', ')
          context.registers[:tracker].register "<%= javascript_include_tag #{paths} %>"
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

Liquid::Template.register_tag('javascripts', PufferPages::Liquid::Tags::Javascripts)
