class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.activated?
        # log user
        helpers.log_in user
        params[:session][:remember_me] == "1" ? helpers.remember(user) : helpers.forget(user)
        redirect_back_or user
        # redirect_to user
      else
        message = "Account not activated. Check your email for the activation link"
        flash[:waring] = message
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  def destroy
    helpers.log_out if helpers.logged_in?
    redirect_to root_url
  end
end
