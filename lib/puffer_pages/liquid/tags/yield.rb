module PufferPages
  module Liquid
    module Tags

      class Yield < ::Liquid::Tag
        Syntax = /(\w+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @name = $1
          else
            @name = PufferPages.primary_page_part_name
          end

          super
        end

        def render(context)
          swallow_nil{context.registers[:page].part(@name).render(context)}
        end
      end

    end
  end
end

Liquid::Template.register_tag('yield', PufferPages::Liquid::Tags::Yield)
