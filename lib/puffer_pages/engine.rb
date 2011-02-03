module PufferPages
  class Engine < Rails::Engine
    config.autoload_paths << File.join(root, 'lib')

    initializer 'puffer_pages.add_cells_paths', :after => :add_view_paths do
      require 'cells'
      ::Cell::Base.prepend_view_path(Cells::DEFAULT_VIEW_PATHS.map { |path| File.join(root, path) })
    end

    initializer 'puffer_pages.add_puffer_pages_route', :after => :add_builtin_route do |app|
      app.routes_reloader.paths << File.join(root, 'config/puffer_routes.rb')
    end
  end
end
