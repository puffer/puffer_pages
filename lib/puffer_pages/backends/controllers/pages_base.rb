class PufferPages::PagesBase < Puffer::TreeBase
  helper :puffer_pages

  setup do
    group :pages
    model_name :page
  end

  tree do
    field :name, :render => :tree_page
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
  #   field :title
  #   field :description
  #   field :keywords
  #   field :'page_parts.name'
  #   field :'page_parts.body'
  # end

  form do
    field :name
    field :slug
    field :page_parts, :type => :page_parts, :localized => PufferPages.localize? do
      field :body, :type => :codemirror, :input_only => true
      field :locale, :type => :hidden, :html => { :data => { :acts => 'locale' } }
      field :name, :type => :hidden, :html => { :data => { :acts => 'name' } }
      field :_destroy, :type => :hidden, :html => { :data => { :acts => 'destroy' } }
    end
    field :layout_name, :select => :possible_layouts, :include_blank => false
    field :status, :select => :possible_statuses, :include_blank => false
    field :title
    field :description
    field :keywords
    field :parent_id, :type => :hidden
  end
end
