module PufferPages
  module Liquid
    module Tags

      class Assets < ::Liquid::Tag
        Syntax = /^(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @paths = variables_from_string(markup)
          else
            raise SyntaxError.new("Syntax Error in '#{tag_name}' - Valid syntax: #{tag_name} path [, path, path ...]")
          end

          super
        end

        def render(context)
          paths = @paths.map {|path| "'#{context[path]}'" }.join(', ')

          erb = case @tag_name
          when 'javascripts'
            "<%= javascript_include_tag #{paths} %>"
          when 'stylesheets'
            "<%= stylesheet_link_tag #{paths} %>"
          end

          context.registers[:tracker].register(erb)
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

Liquid::Template.register_tag('javascripts', PufferPages::Liquid::Tags::Assets)
Liquid::Template.register_tag('stylesheets', PufferPages::Liquid::Tags::Assets)
