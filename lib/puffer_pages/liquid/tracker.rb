module PufferPages
  module Liquid
    class Tracker

      def initialize
        @ids = []
      end

      def register content
        @ids << uid
        content.gsub(/<%/, "<#{@ids.last}%").gsub(/%>/, "%#{@ids.last}>")
      end

      def cleanup text
        ids = @ids.join('|')
        @ids = []
        text = text.gsub(/<%/, "&lt;%").gsub(/%>/, "%&gt;")# unless Cobalt.config[:allow_erb]
        text.gsub(/<(#{ids})%/, "<%").gsub(/%(#{ids})>/, "%>")
      end

      private

      def uid
        Digest::MD5.hexdigest("#{rand}#{Time.now.to_f}")
      end

    end
  end
end
