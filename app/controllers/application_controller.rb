class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :public_page?

  private

  def authenticate_user!
    redirect_to login_path unless current_user
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def public_page?
    request.path == "/" ||
    request.path.start_with?("/posts/") ||
    request.path.start_with?("/sessions")
  end

  helper_method :current_user
end
