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

    def render_template template, page, options = {}
      template = ::Liquid::Template.parse(template)
      options = normalize_render_options(options)

      tracker.cleanup template.render(options[:drops], :registers => {
        :tracker => tracker,
        :page => page,
        :file_system => PufferPages::Liquid::FileSystem.new
      }.reverse_merge!(options[:registers]))
    end

    def tracker
      @tracker ||= PufferPages::Liquid::Tracker.new
    end

  end
end