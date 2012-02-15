module PufferPages
  class Renderer < ActionView::TemplateRenderer
    def determine_template(options)
      puffer_page = options.delete(:partial) if options[:partial].is_a?(PufferPages::Page)
      puffer_page = puffer_pages_template(options[:action].presence || options[:file]) unless puffer_page
      @view.assign(@view.assigns.merge!(
        'puffer_page' => puffer_page,
        'puffer_page_drops' => puffer_page_drops
      ))

      super
    rescue ActionView::MissingTemplate
      options[:text] = ''
      super
    end

    def find_layout(layout, keys)
      layout = "<%= render :inline => @puffer_page.render(default_drops.merge(@puffer_page_drops)),
        :layout => @puffer_page.layout_for_render %>"

      handler = ActionView::Template.handler_for_extension("erb")
      ActionView::Template.new(layout, "puffer pages layout wrapper", handler, :locals => keys)
    end

    def puffer_pages_template(suggest)
      ::Page.find_layout_page(suggest.presence || @view.request.path_info)
    end

    def puffer_page_drops
      @view.assigns.inject({}) do |drops, (key, value)|
        drops[key] = value if value.respond_to?(:to_liquid)
        drops
      end.stringify_keys
    end
  end
end