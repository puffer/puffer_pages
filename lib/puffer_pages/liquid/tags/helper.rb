module PufferPages
  module Liquid
    module Tags

      class Helper < ::Liquid::Tag
        def render(context)
          context.registers[:tracker].register("<%= #{@tag_name} %>")
        end
      end

    end
  end
end

Liquid::Template.register_tag('csrf_meta_tags', PufferPages::Liquid::Tags::Helper)
