module PufferPages
  autoload :SnippetsBase, 'puffer_pages/backends/controllers/snippets_base'
  autoload :LayoutsBase, 'puffer_pages/backends/controllers/layouts_base'
  autoload :PagesBase, 'puffer_pages/backends/controllers/pages_base'
  autoload :OriginsBase, 'puffer_pages/backends/controllers/origins_base'

  class PufferPagesError < StandardError
  end

  class DraftPage < PufferPagesError
  end

  class LayoutMissed < PufferPagesError
  end

  class ImportFailed < PufferPagesError
  end

  mattr_accessor :primary_page_part_name
  self.primary_page_part_name = 'body'

  mattr_accessor :single_section_page_path
  self.single_section_page_path = false

  mattr_accessor :localize
  self.localize = false

  mattr_accessor :access_token
  self.access_token = nil

  mattr_accessor :export_path
  self.export_path = '/admin/origins/export'

  mattr_accessor :install_i18n_backend
  self.install_i18n_backend = true

  def self.setup
    yield self
  end

  def self.i18n_backend
    @i18n_backend ||= PufferPages::Liquid::Backend.new
  end
end

require 'puffer'
require 'liquid'
require 'uuidtools'
require 'activeuuid'
require 'nested_set'
require 'contextuality'

require 'puffer_pages/helpers'
require 'puffer_pages/engine'
require 'puffer_pages/backends'
require 'puffer_pages/handlers'
require 'puffer_pages/migrations'
require 'puffer_pages/log_subscriber'
require 'puffer_pages/extensions/core'
require 'puffer_pages/extensions/context'
require 'puffer_pages/extensions/renderer'
require 'puffer_pages/extensions/pagenator'

require 'puffer_pages/liquid/tags/url'
require 'puffer_pages/liquid/tags/yield'
require 'puffer_pages/liquid/tags/array'
require 'puffer_pages/liquid/tags/assets'
require 'puffer_pages/liquid/tags/image'
require 'puffer_pages/liquid/tags/helper'
require 'puffer_pages/liquid/tags/render'
require 'puffer_pages/liquid/tags/scope'
require 'puffer_pages/liquid/tags/super'
require 'puffer_pages/liquid/tags/include'
require 'puffer_pages/liquid/tags/partials'
require 'puffer_pages/liquid/tags/translate'
require 'puffer_pages/liquid/tags/javascript'
