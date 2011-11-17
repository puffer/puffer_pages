class Admin::ArticlesController < Puffer::Base

  setup do
    group :articles
  end

  index do
    field :title
    field :slug
    field :body
  end

  form do
    field :title
    field :body
  end

end
