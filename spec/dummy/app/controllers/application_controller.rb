class ApplicationController < ActionController::Base
  protect_from_forgery

  around_filter :locale_context

  def locale_context &block
    params[:locale].present? ? I18n.with_locale(params[:locale], &block) : block.call
  end

  def has_puffer_access? namespace
    true
  end

  def current_puffer_user
  	nil
  end
end
