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

      def cleanup content
        ids = @ids.join('|')
        content = content.gsub(/<%/, "&lt;%").gsub(/%>/, "%&gt;")# unless PufferPages.allow_erb
        content.gsub(/<(#{ids})%/, "<%").gsub(/%(#{ids})>/, "%>")
      end

    end
  end
end
