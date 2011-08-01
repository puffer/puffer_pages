module PufferPagesHelper

  def possible_layouts
    inherited_layout + (application_layouts + puffer_layouts).uniq.sort
  end

  def application_layouts
    Dir.glob("#{view_paths.first}/layouts/[^_]*").flatten.map {|path| File.basename(path).gsub(/\..*$/, '')}.uniq
  end

  def puffer_layouts
    Layout.order(:name).all.map(&:name)
  end

  def inherited_layout
    record.inherited_layout_name && !record.root? ? [[t('puffer_pages.inherited_layout', :name => record.inherited_layout_name), '']] : []
  end

  def possible_statuses
    Page.statuses
  end

  def tree_page record
    render :partial => 'tree_page', :object => record
  end

end
