module PufferPages
  module Liquid
    class Tracker

      def initialize
        @ids = []
      end

      def register content
        @ids << Digest::MD5.hexdigest(SecureRandom.uuid)
        content.gsub(/<%/, "<#{@ids.last}%").gsub(/%>/, "%#{@ids.last}>")
      end

      def cleanup text
        ids = @ids.join('|')
        @ids = []
        text = text.gsub(/<%/, "&lt;%").gsub(/%>/, "%&gt;")# unless PufferPages.config[:allow_erb]
        text.gsub(/<(#{ids})%/, "<%").gsub(/%(#{ids})>/, "%>")
      end

    end
  end
end
