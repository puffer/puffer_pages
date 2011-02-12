module PufferPages
  module Liquid
    module Tags

      class RenderSnippet < ::Liquid::Tag
        Syntax = /(#{::Liquid::QuotedFragment}+)/

        def initialize(tag_name, markup, tokens)
          if markup =~ Syntax
            @name = $1
          else
            raise SyntaxError.new("Syntax Error in 'render_snippet' - Valid syntax: render_snippet snipper_name")
          end

          super
        end

        def render(context)
          name = context[@name]
          snippet = Snippet.find_by_name(name)
          if snippet
            snippet.render(context)
          else
            raise ArgumentError.new("Argument error in 'render_snippet' - Can not find snippet named '#{name}'")
          end
        end
      end

    end
  end
end

Liquid::Template.register_tag('render_snippet', PufferPages::Liquid::Tags::RenderSnippet)
