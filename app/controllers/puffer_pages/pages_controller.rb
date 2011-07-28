class PufferPages::PagesController < Puffer::TreeBase
  unloadable

  helper :puffer_pages

  setup do
    group :pages
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
    field :page_parts, :type => :page_parts
    field :layout_name, :select => :possible_layouts
    field :status, :select => :possible_statuses
    field :title
    field :description
    field :keywords
    field :parent_id, :type => :hidden
  end

end
