module PufferPages
  class Renderer < ActionView::TemplateRenderer
    def render(context, options)
      @view = context
      super
    end

    def determine_template(options)
      @view.assign(@view.assigns.merge!('puffer_page' => options[:puffer_page]))

      super
    rescue ActionView::MissingTemplate
      options[:text] = ''
      super
    end

    def find_layout(layout, keys)
      layout = "<%= render(:inline => @puffer_page.render(puffer_pages_context),
        :layout => @puffer_page.layout_for_render) %>"

      handler = ActionView::Template.handler_for_extension("erb")
      ActionView::Template.new(layout, "puffer pages layout wrapper", handler, :locals => keys)
    end
  end
end