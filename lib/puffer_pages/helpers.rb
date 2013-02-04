module PufferPages
  module Helpers
    def puffer_pages_context
      drops = assigns.each_with_object({}) do |(key, value), result|
        result[key] = value if value.respond_to?(:to_liquid)
      end
      registers = assigns.each_with_object({}) do |(key, value), result|
        result[key] = value
      end

      { drops: drops, registers: registers.merge!(:controller => controller) }
    end
  end
end