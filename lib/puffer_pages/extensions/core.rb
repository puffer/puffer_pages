Array.class_eval do
  def arranged
    arranged = ActiveSupport::OrderedHash.new
    insertion_points = [arranged]
    depth = 0
    each do |node|
      next if node.depth > depth && insertion_points.last.keys.last && node.parent_id != insertion_points.last.keys.last.id
      insertion_points.push insertion_points.last.values.last if node.depth > depth
      (depth - node.depth).times { insertion_points.pop } if node.depth < depth
      insertion_points.last.merge! node => ActiveSupport::OrderedHash.new
      depth = node.depth
    end
    arranged
  end
end
