class Puffer::DashboardController < Puffer::Dashboard

  def index
    p Rails.application.routes.puffer
  end

end
