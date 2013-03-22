module PufferPages
  class Engine < Rails::Engine
    engine_name :puffer_pages

    config.autoload_paths << File.join(root, 'lib')
    config.puffer_pages = PufferPages.config

    initializer 'puffer_pages.install_i18n_backend', after: 'build_middleware_stack' do
      if PufferPages.install_i18n_backend
        I18n.backend = I18n::Backend::Chain.new(PufferPages.i18n_backend, I18n.backend)
      end
    end

    initializer 'puffer_pages.initialize_cache', after: 'initialize_cache' do
      PufferPages.cache_store = config.puffer_pages.cache_store || ::Rails.cache
      PufferPages.config.perform_caching = config.action_controller.perform_caching
    end

    ActiveSupport.on_load(:action_view) do
      ActionView::Base.send :include, PufferPages::Helpers
    end
  end
end
