module PufferPages
  module Liquid
    module Tags

      class Yield < ::Liquid::Tag
        Syntax = /(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @name = $1
          else
            @name = "'#{PufferPages.primary_page_part_name}'"
          end

          super
        end

        def render(context)
          name = context[@name]
          part = context.registers[:page].part(name)
          if part
            part.render(context)
          else
            raise ArgumentError.new("Argument error in 'yield' - Can not find page part named '#{name}'")
          end
        end
      end

    end
  end
end

Liquid::Template.register_tag('yield', PufferPages::Liquid::Tags::Yield)
