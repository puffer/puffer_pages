module PufferPages
  module Rspec
    module Matchers

    end
  end
end

require 'puffer_pages/rspec/matchers/render_page'

RSpec::Rails::ControllerExampleGroup.class_eval do
  def puffer_pages_render
    @puffer_pages_render
  end

  included do
    around(:each) do |example|
      @puffer_pages_render = {}
      ActiveSupport::Notifications.subscribe('render_page.puffer_pages') do |name, start, finish, id, payload|
        @puffer_pages_render[payload[:subject]] ||= []
        @puffer_pages_render[payload[:subject]].push payload
      end
      example.run
      ActiveSupport::Notifications.unsubscribe('render_page.puffer_pages')
    end
  end
end
