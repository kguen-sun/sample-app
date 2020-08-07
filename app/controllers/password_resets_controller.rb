class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email].downcase

    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t ".flash_reset_password"
      redirect_to root_url
    else
      flash[:danger] = t ".flash_email_not_found"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add :password, t(".blank_password")
    elsif @user.update user_params.merge reset_digest: nil
      log_in @user
      flash[:success] = t ".flash_reset_success"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def get_user
    @user = User.find_by email: params[:email]
  end

  def valid_user
    return if @user&.can_reset_password? params[:id]

    flash[:danger] = t "password_resets.valid_user.flash_invalid"
    redirect_to root_url
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "password_resets.check_expiration.flash_expired"
    redirect_to root_url
  end
end
