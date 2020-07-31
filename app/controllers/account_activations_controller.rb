class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by email: params[:email]

    if user&.can_activate? params[:id]
      user.activate
      log_in user
      flash[:success] = t ".flash_activated"
      redirect_to user
    else
      flash[:danger] = t ".flash_invalid_activation"
      redirect_to root_url
    end
  end
end
