class PufferPages::PagesBase < Puffer::TreeBase
  helper :puffer_pages

  setup do
    group :pages
    model_name :'puffer_pages/page'
  end

  tree do
    #field :name, :render => :tree_page
    field :name, render: -> { render :partial => 'tree_page', :object => record }
  end

  def new
    @record = resource.new_member
    if !@record.inherited_page_part(PufferPages.primary_page_part_name)
      @record.page_parts.build :name => PufferPages.primary_page_part_name
    end
    respond_with @record
  end

  index do
    field :name
    field :slug
    field :layout_name
    field :status
  end

  # filter do
  #   field :name
  #   field :slug
  #   field :layout_name
  #   field :'page_parts.name'
  #   field :'page_parts.body'
  # end

  form do
    field :parent_id, type: :hidden
    field :name
    field :slug
    field :layout_name, select: :possible_layouts, include_blank: false
    field :status, select: :possible_statuses, include_blank: false
    field :page_parts, type: :page_parts do
      field :handler, type: :handlers, include_blank: false,
        html: { 'data-codemirror-mode-select' => true }
      field :body, type: :codemirror, input_only: true, mode: 'text/x-liquid-html'
      field :name, type: :hidden, html: { data: { acts: 'name' } }
      field :_destroy, type: :hidden, html: { data: { acts: 'destroy' } }
    end
    field :locales, type: :codemirror, mode: 'text/x-yaml'
  end
end
