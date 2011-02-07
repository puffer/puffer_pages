class PufferPages::LayoutsController < Puffer::Base
  unloadable

  configure do
    group :cms
  end

  index do
    field :name
  end

  form do
    field :name
    field :body
  end

end
