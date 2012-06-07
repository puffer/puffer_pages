module PufferPages
  module Renderable
    extend ActiveSupport::Concern

  private

    def normalize_render_options options
      if options.is_a?(Hash) && (options.key?(:drops) || options.key?(:registers))
        drops = options[:drops] || {}
        registers = options[:registers] || {}
      else
        drops = options
        registers = {}
      end
      {:drops => drops.stringify_keys!, :registers => registers.symbolize_keys!}
    end

    def render_liquid template, page, options = {}
      template = ::Liquid::Template.parse(template)
      render_method = Rails.application.config.puffer_pages.raise_errors ? 'render!' : 'render'

      if options.is_a?(::Liquid::Context)
        template.send(render_method, options)
      else
        options = normalize_render_options(options)
        tracker = PufferPages::Liquid::Tracker.new
        tracker.cleanup template.send(render_method, options[:drops], :registers => {
          :file_system => PufferPages::Liquid::FileSystem.new,
          :tracker => tracker,
          :page => page
        }.reverse_merge!(options[:registers]))
      end

    end

  end
end