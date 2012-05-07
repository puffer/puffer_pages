module PufferPages
  module Liquid
    module Tags

      class Render < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @path = $1
          else
            raise SyntaxError.new("Syntax Error in 'render' - Valid syntax: render path")
          end

          super
        end

        def render(context)
          path = context[@path]
          context.registers[:tracker].register("<%= render '#{path}' %>")
        end
      end

    end
  end
end

Liquid::Template.register_tag('render', PufferPages::Liquid::Tags::Render)
