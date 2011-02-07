class PufferPages::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def generate_assets
    directory 'puffer', 'public/puffer'
  end

  def generate_migrations
    directory 'migrate', 'db/migrate'
  end

  def generate_controllers
    directory 'controllers', 'app/controllers/admin'
  end

  def generate_config
    copy_file 'puffer_pages.rb', 'config/initializers/puffer_pages.rb'
  end

end
