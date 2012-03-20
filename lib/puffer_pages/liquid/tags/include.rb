module PufferPages
  module Liquid
    module Tags

      class Include < ::Liquid::Include
        def initialize(tag_name, markup, tokens)
          @tag_name = tag_name
          super
        end

      private

        def _read_template_from_file_system(context)
          file_system = context.registers[:file_system] || Liquid::Template.file_system
          template_name = "#{@tag_name.pluralize}/#{context[@template_name]}"

          file_system.read_template_file(template_name, context)
        end
      end

    end
  end
end

Liquid::Template.register_tag('snippet', PufferPages::Liquid::Tags::Include)
Liquid::Template.register_tag('layout', PufferPages::Liquid::Tags::Include)
