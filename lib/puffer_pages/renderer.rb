module PufferPages
  class Renderer < ActionView::TemplateRenderer
    def determine_template(options)
      puffer_page = options[:puffer_page]
      @view.assign(@view.assigns.merge!(
        'puffer_page' => puffer_page,
        'puffer_page_render_options' => puffer_page_render_options(puffer_page)
      ))

      super
    rescue ActionView::MissingTemplate
      options[:text] = ''
      super
    end

    def find_layout(layout, keys)
      layout = "<%= render(
        :inline => @puffer_page.render(@puffer_page_render_options),
        :layout => @puffer_page.layout_for_render) %>"

      handler = ActionView::Template.handler_for_extension("erb")
      ActionView::Template.new(layout, "puffer pages layout wrapper", handler, :locals => keys)
    end

    def puffer_page_render_options page
      drops, registers = *@view.assigns.partition {|k, v| v.respond_to?(:to_liquid)}.map{|v| Hash[v]}
      {
        :drops => drops.merge!(:self => page.to_drop),
        :registers => registers.merge!(:controller => @view.controller)
      }
    end
  end
end