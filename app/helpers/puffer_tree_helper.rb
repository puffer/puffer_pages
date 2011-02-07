module PufferTreeHelper

  def puffer_tree hash, options = {}, &block
    content_tag :ul, options do
      hash.keys.each do |node|
        block.call node, render_tree(hash[node], &block)
      end
    end if hash.present?
  end

end
