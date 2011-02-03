class PufferPages::LayoutsController < PufferPages::Base
  unloadable

  index do
    field :name
  end

  form do
    field :name
    field :body
  end

end
