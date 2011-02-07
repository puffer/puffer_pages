module Puffer
  class TreeBase < Puffer::Base
    unloadable

    view_paths_fallbacks_prepend :puffer_tree
    helper :puffer_tree

    define_fields :tree

    def self.tree_fields
      _tree_fields.presence || index_fields
    end

    def index
      return super if params[:search]
      @records = resource.collection_scope.includes(resource.includes).arrange
      render 'tree'
    end

    member do
      get :inherit, :label => 'new page'
    end

    def inherit
      @parent = resource.member
      @record = @parent.children.new
      render 'new'
    end

  end
end
