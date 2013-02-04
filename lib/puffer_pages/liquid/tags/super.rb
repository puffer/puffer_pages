module PufferPages
  module Liquid
    module Tags

      class Super < ::Liquid::Include
        def initialize(tag_name, markup, tokens)
          @attributes = {}
          markup.scan(::Liquid::TagAttributes) do |key, value|
            @attributes[key] = value
          end
        end

        def render(context)
          source = _read_template_from_file_system(context)

          context.stack do
            @attributes.each do |key, value|
              context[key] = context[value]
            end

            source.render(context)
          end
        end

      private
        def _read_template_from_file_system(context)
          file_system = context.registers[:file_system] || Liquid::Template.file_system
          file_system.read_template_file(:super, context)
        end
      end

    end
  end
end

Liquid::Template.register_tag('super', PufferPages::Liquid::Tags::Super)
