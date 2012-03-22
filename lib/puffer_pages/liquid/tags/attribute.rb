module PufferPages
  module Liquid
    module Tags

      class Attribute < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @page = $1
          elsif markup.blank?
            @page = 'self'
          else
            raise SyntaxError.new("Syntax Error in '#{tag_name}' - Valid syntax: #{tag_name} [page]")
          end

          super
        end

        def render(context)
          page = context[@page]
          page = context.registers[:page] unless page.is_a?(PufferPages::Liquid::PageDrop)

          context.stack do
            context['self'] = page
            ::Liquid::Template.parse(page[@tag_name]).render(context)
          end
        end
      end

    end
  end
end

Liquid::Template.register_tag('name', PufferPages::Liquid::Tags::Attribute)
Liquid::Template.register_tag('title', PufferPages::Liquid::Tags::Attribute)
Liquid::Template.register_tag('keywords', PufferPages::Liquid::Tags::Attribute)
Liquid::Template.register_tag('description', PufferPages::Liquid::Tags::Attribute)
