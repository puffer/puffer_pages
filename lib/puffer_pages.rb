module PufferPages

  mattr_accessor :primary_page_part_name
  self.primary_page_part_name = 'body'

  mattr_accessor :single_section_page_path
  self.single_section_page_path = false

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
#require 'puffer_pages/liquid/tags/yield'
require 'puffer_pages/liquid/tags/stylesheets'
require 'puffer_pages/liquid/tags/javascripts'

Puffer.setup do |config|
  config.javascripts += %w(right-dialog right-tabs puffer_pages)
  config.stylesheets += %w(puffer_pages puffer_tree)
end
