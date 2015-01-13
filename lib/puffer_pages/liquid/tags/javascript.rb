module PufferPages
  module Liquid
    module Tags

      class Javascript < ::Liquid::Block
        def render(context)
          context.registers[:tracker].register("<%= javascript_tag do %>#{super}<% end %>")
        end

        def blank?
          false
        end
      end

    end
  end
end

Liquid::Template.register_tag('javascript', PufferPages::Liquid::Tags::Javascript)
