module PufferPages
  module Liquid
    module Tags

      class Include < ::Liquid::Include
        def render(context)
          source = _read_template_from_file_system(context)
          partial = ::Liquid::Template.parse(source)
          variable = context[@variable_name || @template_name[1..-2]]

          context.stack do
            context[:page_part] = source if source.is_a?(::PagePart)

            @attributes.each do |key, value|
              context[key] = context[value]
            end

            if variable.is_a?(Array)
              variable.collect do |variable|
                context[@template_name[1..-2]] = variable
                partial.render(context)
              end
            else
              context[@template_name[1..-2]] = variable
              partial.render(context)
            end
          end
        end
      end

    end
  end
end

Liquid::Template.register_tag('include', PufferPages::Liquid::Tags::Include)
