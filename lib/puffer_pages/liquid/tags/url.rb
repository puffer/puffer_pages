module PufferPages
  module Liquid
    module Tags

      class Url < ::Liquid::Tag
        Syntax = /^(#{::Liquid::VariableSignature}+)\s*(.*)\s*/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax

            @helper_name = $1
            @arguments = []
            @attributes = {}

            @arguments = $2.split(',')
            attributes = @arguments.pop if @arguments.last && @arguments.last.strip =~ /(#{::Liquid::TagAttributes})/

            @arguments = @arguments.map do |var|
              var.strip =~ /(#{::Liquid::QuotedFragment})/
              $1 ? $1 : nil
            end.compact

            attributes.scan(::Liquid::TagAttributes) do |key, value|
              @attributes[key] = value
            end if attributes.present?
          else
            raise SyntaxError.new("Error in tag '#{tag_name}' - Valid syntax: #{tag_name} helper_name [object, object...] [, option:value option:value...]")
          end

          super
        end

        def render(context)
          key = context[@key]
          arguments = @arguments.map do |argument|
            argument = context[argument]
            argument.to_param if argument.is_a?(::Liquid::Drop)
            argument
          end
          attributes = @attributes.inject({}) do |result, (key, value)|
            result[key.to_sym] = context[value]
            result
          end
          attributes.merge(:path_only => true) if @tag_name == 'path'

          context.registers[:controller].send("#{@helper_name}_#{@tag_name}", *arguments, attributes)
        end

      end

    end
  end
end

Liquid::Template.register_tag('path', PufferPages::Liquid::Tags::Url)
Liquid::Template.register_tag('url', PufferPages::Liquid::Tags::Url)
