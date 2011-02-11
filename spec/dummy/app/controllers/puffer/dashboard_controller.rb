class Puffer::DashboardController < Puffer::DashboardBase

  def index
    p Rails.application.routes.puffer
  end

end
