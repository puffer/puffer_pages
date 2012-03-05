module PufferPages
  class Renderer < ActionView::TemplateRenderer
    def determine_template(options)
      puffer_page = options.delete(:partial) if options[:partial].is_a?(PufferPages::Page)
      puffer_page = puffer_pages_template(options[:action].presence || options[:file]) unless puffer_page
      @view.assign(@view.assigns.merge!(
        'puffer_page' => puffer_page,
        'puffer_page_render_options' => puffer_page_render_options
      ))

      super
    rescue ActionView::MissingTemplate
      options[:text] = ''
      super
    end

    def find_layout(layout, keys)
      layout = "<% @puffer_page_render_options[:drops].merge!(default_drops) %><%= render(
        :inline => @puffer_page.render(@puffer_page_render_options),
        :layout => @puffer_page.layout_for_render) %>"

      handler = ActionView::Template.handler_for_extension("erb")
      ActionView::Template.new(layout, "puffer pages layout wrapper", handler, :locals => keys)
    end

    def puffer_pages_template(suggest)
      ::Page.find_layout_page(suggest.presence || @view.request.path_info)
    end

    def puffer_page_render_options
      drops, registers = {}, {}
      @view.assigns.each do |key, value|
        if value.respond_to?(:to_liquid)
          drops[key] = value
        else
          registers[key] = value
        end
      end
      {:drops => drops, :registers => registers}
    end
  end
end