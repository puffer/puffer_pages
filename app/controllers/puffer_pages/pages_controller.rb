class PufferPages::PagesController < PufferPages::Base
  unloadable

  index do
    field :name
    field :slug
    field :layout_name
    field :status
  end

  form do
    field :name
    field :slug
    field :layout_name
    field :status, :select => Page.statuses
    field :title
    field :description
    field :keywords
  end
end
