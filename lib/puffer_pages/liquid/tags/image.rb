module PufferPages
  module Liquid
    module Tags

      class Image < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment})/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @path = $1
          elsif markup.blank?
            @path = nil
          else
            raise SyntaxError.new("Syntax Error in 'image' - Valid syntax: image '/path/to/image'")
          end

          @attributes = {}
          markup.scan(::Liquid::TagAttributes) do |key, value|
            @attributes[key] = value
          end

          super
        end

        def render(context)
          attributes = {}
          @attributes.each do |key, value|
            attributes[key] = context[value]
          end

          erb = "<%= image_tag #{@path}, #{attributes.inspect} %>"

          context.registers[:tracker].register(erb)
        end
      end

    end
  end
end

Liquid::Template.register_tag('image', PufferPages::Liquid::Tags::Image)
