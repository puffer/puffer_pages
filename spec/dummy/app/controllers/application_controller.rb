class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :setup_locale

  def setup_locale
    I18n.locale = params[:locale].presence || I18n.default_locale
  end

  def has_puffer_access? namespace
    true
  end

  def current_puffer_user
  	nil
  end
end
