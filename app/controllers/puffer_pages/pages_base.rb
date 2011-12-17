class PufferPages::PagesBase < Puffer::TreeBase
  unloadable

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

  form do
    field :name
    field :slug
    field :location
    field :page_parts, :type => :page_parts do
      field :body, :type => :codemirror, :input_only => true
      field :name, :type => :hidden
      field :_destroy, :type => :hidden, :html => { :class => 'destroy_mark' }
    end
    field :layout_name, :select => :possible_layouts, :include_blank => false
    field :status, :select => :possible_statuses, :include_blank => false
    field :title
    field :description
    field :keywords
    field :parent_id, :type => :hidden
  end

end
