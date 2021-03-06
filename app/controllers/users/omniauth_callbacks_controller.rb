class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include Devise::Controllers::Rememberable
  skip_before_filter :verify_authenticity_token, :only => [:open_id]

  def open_id
    @user = User.find_for_steam_id(request.env["omniauth.auth"], current_user)
    
    if @user != nil && @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Steam"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.steam"] = User.get_steam_user_info(request.env["omniauth.auth"])
      redirect_to end
    new_user_registration_url
  end

  def failure
    #render :text => "Authorization failed."
    render 'devise/registration/failed_auth'
  end


end