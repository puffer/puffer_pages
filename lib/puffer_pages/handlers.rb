module PufferPages
  module Handlers
    class HandlerMissing < Exception; end

    def self.handlers
      @handlers ||= HashWithIndifferentAccess.new
    end

    def self.register klass, *types
      handlers.merge! Hash[types.flatten.map { |type| [type, klass.new(type)] }]
    end

    def self.process type, *args
      raise HandlerMissing.new("Can not find handler for '#{type}' type") unless handlers[type]
      handlers[type].process(*args)
    end

    def self.select
      handlers.values.map { |handler| [
        I18n.t("puffer_pages.handlers.#{handler.type}"),
        handler.type,
        { 'data-codemirror-mode' => handler.codemirror_mode }
      ] }
    end
  end
end

require 'puffer_pages/handlers/base'
require 'puffer_pages/handlers/yaml'
