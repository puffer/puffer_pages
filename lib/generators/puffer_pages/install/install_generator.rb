class PufferPages::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def generate_controllers
    directory 'controllers', 'app/controllers/admin'
  end

  def generate_routes
    route "namespace :admin do\n    resources :pages\n    resources :layouts\n    resources :snippets\n  end"
  end

end
