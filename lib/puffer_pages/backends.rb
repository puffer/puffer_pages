module PufferPages
  module Backends
    autoload :Snippet, 'puffer_pages/backends/models/snippet'
    autoload :Layout, 'puffer_pages/backends/models/layout'
    autoload :Page, 'puffer_pages/backends/models/page'
    autoload :PagePart, 'puffer_pages/backends/models/page_part'
    autoload :Origin, 'puffer_pages/backends/models/origin'

    module Mixins
      autoload :Renderable, 'puffer_pages/backends/models/mixins/renderable'
      autoload :Importable, 'puffer_pages/backends/models/mixins/importable'
      autoload :Translatable, 'puffer_pages/backends/models/mixins/translatable'
      autoload :Localable, 'puffer_pages/backends/models/mixins/localable'
    end
  end
end
