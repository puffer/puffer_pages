class PufferPages::SnippetsBase < Puffer::Base
  unloadable

  layout 'puffer_pages'

  setup do
    group :pages
  end

  index do
    field :name
  end

  form do
    field :name
    field :body, :html => {:codemirror => true}
  end

end
