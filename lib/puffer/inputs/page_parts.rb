module Puffer
  module Inputs
    class PageParts < Puffer::Inputs::Base

      def html
        template.render :partial => 'page_parts', :locals => {:builder => builder}
      end


    end
  end
end
