module Puffer
  module Inputs
    class PagePartsBody < Puffer::Inputs::Text

      def html
        input
      end

    end
  end
end

