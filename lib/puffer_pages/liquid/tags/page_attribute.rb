module PufferPages
  module Liquid
    module Tags

      class PageAttribute < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          @tag_name = tag_name

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

          context.stack do
            context['self'] = page
            ::Liquid::Template.parse(page[@tag_name]).render(context)
          end
        end
      end

    end
  end
end

Liquid::Template.register_tag('name', PufferPages::Liquid::Tags::PageAttribute)
Liquid::Template.register_tag('title', PufferPages::Liquid::Tags::PageAttribute)
Liquid::Template.register_tag('keywords', PufferPages::Liquid::Tags::PageAttribute)
Liquid::Template.register_tag('description', PufferPages::Liquid::Tags::PageAttribute)
