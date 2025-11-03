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
      session[:user_id] = user.id
      redirect_to admin_path, notice: "Logged in successfully"
    else
      flash.now[:alert] = "Invalid email or password"
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  # Logs the user out
  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out"
  end
end
