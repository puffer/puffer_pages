class PufferPages::PagesController < PufferPages::Base
  unloadable

  index do
    field :name
    field :slug
    field :layout_name
    field :status
  end

  form do
    field :parent_id, :type => :hidden
    field :name
    field :slug
    field :layout_name, :select => :possible_layouts
    field :status, :select => Page.statuses
    field :title
    field :description
    field :keywords
  end

  member do
    get :inherit
  end

  def inherit
    @parent = resource.member
    @page = @parent.children.new
    render 'new'
  end

end
