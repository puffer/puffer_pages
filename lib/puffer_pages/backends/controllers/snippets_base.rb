class PufferPages::SnippetsBase < Puffer::Base
  setup do
    group :pages
    model_name :'puffer_pages/snippet'
  end

  index do
    field :name
  end

  form do
    field :name
    field :body, type: :codemirror, mode: 'text/x-liquid-html'
  end
end
