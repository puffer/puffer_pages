module PufferPages
  class Renderer < ActionView::TemplateRenderer
    def determine_template(options)
      puffer_page = options[:partial] if options[:partial].is_a?(Page)
      puffer_page = puffer_pages_template(options[:action].presence || options[:file]) unless puffer_page
      @view.assign('puffer_page' => puffer_page)
      super
    rescue ActionView::MissingTemplate
      options[:text] = ''
      super
    end

    def find_layout(layout, keys)
      layout = "<%= render :inline => @puffer_page.render(default_drops.reverse_merge(drops.presence || {})),
        :layout => @puffer_page.layout_for_render %>"

      handler = ActionView::Template.handler_for_extension("erb")
      ActionView::Template.new(layout, "puffer pages layout wrapper", handler, :locals => keys)
    end

    def puffer_pages_template(suggest)
      ::Page.find_layout_page(suggest.presence || @view.request.path_info)
    end
  end
end