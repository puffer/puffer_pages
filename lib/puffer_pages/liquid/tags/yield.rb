module PufferPages
  module Liquid
    module Tags

      class Yield < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @name = $1
          elsif markup.blank?
            @name = nil
          else
            raise SyntaxError.new("Syntax Error in 'yield' - Valid syntax: yield [content_name]")
          end

          super
        end

        def render(context)
          context.registers[:tracker].register(@name ?
            "<%= yield :'#{@name}' %>" :
            "<%= yield %>")
        end

        def blank?
          false
        end
      end

    end
  end
end

Liquid::Template.register_tag('yield', PufferPages::Liquid::Tags::Yield)
