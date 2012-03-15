class PufferPages::LayoutsBase < Puffer::Base
  setup do
    group :pages
    model_name :layout
  end

  index do
    field :name
  end

  form do
    field :name
    field :body, :type => :codemirror
  end
end
