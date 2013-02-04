class PufferPages::LayoutsBase < Puffer::Base
  setup do
    group :pages
    model_name :'puffer_pages/layout'
  end

  index do
    field :name
  end

  form do
    field :name
    field :body, type: :codemirror, mode: 'text/x-liquid-html'
  end
end
