module PufferPages
  module Liquid
    module Tags

      class Javascript < ::Liquid::Block
        def render(context)
          context.registers[:tracker].register("<%= javascript_tag \"#{super}\" %>")
        end
      end

    end
  end
end

Liquid::Template.register_tag('javascript', PufferPages::Liquid::Tags::Javascript)
