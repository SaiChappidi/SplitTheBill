class SessionsController < ApplicationController
  # GET /login
  def new
    redirect_to root_path if logged_in?
  end

  # POST /login
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # verify user exists & password matches the hash
    if user && user.authenticate(params[:session][:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: "Logged in successfully. Welcome, #{user.name}!"
    else
      flash.now[:alert] = "Invalid email or password combination."
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /logout
  def destroy
    session[:user_id] = nil
    flash[:notice] = "You have been logged out."
    redirect_to root_path
  end
end
