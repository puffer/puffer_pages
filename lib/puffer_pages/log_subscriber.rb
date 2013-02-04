module PufferPages
  class LogSubscriber < ActiveSupport::LogSubscriber
    def render_page event
      message = "  PufferPages: rendered page /#{event.payload[:subject].location} #{duration(event)}"
      info message
    end

    def render_page_part event
      message = "  PufferPages: rendered page_part #{event.payload[:subject].name} #{duration(event)}"
      debug message
    end

    def render_layout event
      message = "  PufferPages: rendered layout #{event.payload[:subject].name} #{duration(event)}"
      debug message
    end

    def render_snippet event
      message = "  PufferPages: rendered snippet #{event.payload[:subject].name} #{duration(event)}"
      debug message
    end

    def duration event
      '(%.1fms)' % event.duration
    end
  end
end

PufferPages::LogSubscriber.attach_to :puffer_pages
