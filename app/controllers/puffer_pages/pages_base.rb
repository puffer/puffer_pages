class PufferPages::PagesBase < Puffer::TreeBase
  unloadable

  layout 'puffer_pages'

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
    field :page_parts, :type => :page_parts do
      field :body, :type => :page_part_body, :html => {:codemirror => true}
      field :name, :type => :hidden
      field :_destroy, :type => :hidden, :html => { :class => 'destroy_mark' }
    end
    field :layout_name, :select => :possible_layouts
    field :status, :select => :possible_statuses
    field :title
    field :description
    field :keywords
    field :parent_id, :type => :hidden
  end

end
