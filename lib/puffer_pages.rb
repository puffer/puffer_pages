module PufferPages

  autoload :Snippet, 'puffer_pages/backends/models/snippet'
  autoload :Layout, 'puffer_pages/backends/models/layout'
  autoload :Page, 'puffer_pages/backends/models/page'
  autoload :PagePart, 'puffer_pages/backends/models/page_part'
  autoload :Renderable, 'puffer_pages/backends/models/renderable'

  autoload :SnippetsBase, 'puffer_pages/backends/controllers/snippets_base'
  autoload :LayoutsBase, 'puffer_pages/backends/controllers/layouts_base'
  autoload :PagesBase, 'puffer_pages/backends/controllers/pages_base'

  class PufferPagesError < StandardError
  end

  class DraftPage < PufferPagesError
  end

  class LayoutMissed < PufferPagesError
  end

  mattr_accessor :primary_page_part_name
  self.primary_page_part_name = 'body'

  mattr_accessor :single_section_page_path
  self.single_section_page_path = false

  mattr_accessor :codemirror_buttons
  self.codemirror_buttons = [:fullscreen]

  def self.setup
    yield self
  end

end

require 'puffer'
require 'liquid'
require 'nested_set'

require 'puffer_pages/engine'
require 'puffer_pages/extensions/core'
require 'puffer_pages/extensions/mapper'
require 'puffer_pages/extensions/renderer'
require 'puffer_pages/extensions/controller'
require 'puffer_pages/extensions/pagenator'

require 'puffer_pages/liquid/tags/yield'
require 'puffer_pages/liquid/tags/assets'
require 'puffer_pages/liquid/tags/super'
require 'puffer_pages/liquid/tags/include'
require 'puffer_pages/liquid/tags/partials'
require 'puffer_pages/liquid/tags/attribute'
