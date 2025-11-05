class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :check_session_expiry
  before_action :authenticate_user!, unless: :public_page?

  private

  def check_session_expiry
    return unless session[:user_id] # Skip if not logged in

    # Check if session has an expiry time set
    if session[:expires_at].present?
      expires_at = Time.parse(session[:expires_at].to_s)

      # If session has expired, logout the user
      if expires_at < Time.current
        reset_session
        redirect_to login_path, alert: "Your session has expired. Please login again."
      end
    end
  end

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
