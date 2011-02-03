class PufferPages::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path('../templates', __FILE__)

  def generate_migrations
    directory 'migrate', 'db/migrate'
  end

  def generate_controllers
    directory 'controllers', 'app/controllers/admin'
  end

end
