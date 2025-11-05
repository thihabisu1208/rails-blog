class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create ]

  # GET /login
  # Shows the login form
  def new
  end

  # POST /sessions
  # Processes the login form submission
  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      # Security: Reset session to prevent session fixation attacks
      # This generates a new session ID, making any old session ID useless
      reset_session

      # Set the user_id in the new session
      session[:user_id] = user.id

      # Set session expiry (2 weeks from now)
      session[:expires_at] = 2.weeks.from_now

      redirect_to admin_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  # Logs the user out
  def destroy
    # Security: Completely reset session instead of just clearing user_id
    # This ensures all session data is cleared, not just the user_id
    reset_session
    redirect_to root_path, notice: "Logged out"
  end
end
