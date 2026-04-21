class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?

  # returns currently logged-in user 
  def current_user
    # memoize the lookup to avoid repeated database queries 
    if session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  def logged_in?
    !current_user.nil?
  end

  # filter to restrict access to specific pages
  def logged_in_user
    unless logged_in?
      redirect_to login_url, alert: "Please log in to continue." 
    end
  end
end