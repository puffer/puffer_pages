module PufferPages
  class LogSubscriber < ActiveSupport::LogSubscriber
    def render_page event
      message = "  PufferPages: rendered page /#{event.payload[:subject].location} #{duration(event)}"
      persistent_log event.payload[:subject].location, event.duration
      debug message
    end

    def render_page_part event
      message = "  PufferPages: rendered page_part #{event.payload[:subject].name} #{duration(event)}"
      persistent_log event.payload[:subject].name, event.duration
      debug message
    end

    def render_layout event
      message = "  PufferPages: rendered layout #{event.payload[:subject].name} #{duration(event)}"
      persistent_log event.payload[:subject].name, event.duration
      debug message
    end

    def render_snippet event
      message = "  PufferPages: rendered snippet #{event.payload[:subject].name} #{duration(event)}"
      persistent_log event.payload[:subject].name, event.duration
      debug message
    end

    def persistent_log id, duration
      if Rails.env != 'development'
        message = "Template debug - id: #{CmsEngine::DomainConfig.current.locale}_#{id} time: #{duration}"
        debug message
      end
    end

    def duration event
      '(%.1fms)' % event.duration
    end
  end
end

PufferPages::LogSubscriber.attach_to :puffer_pages
