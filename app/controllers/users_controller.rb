class UsersController < ApplicationController
  before_action :load_exists_user, only: %i(show edit destroy)
  before_action :logged_in_user, except: %i(show new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.is_activated.page params[:page]
  end

  def show
    return if @user.activated

    flash[:danger] = t ".flash_not_found"
    redirect_to root_url
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params

    if @user.save
      @user.send_activation_email
      flash[:info] = t ".flash_activate"
      redirect_to root_url
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".flash_updated"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    @user.destroy
    flash[:success] = t ".flash_destroyed"
    redirect_to users_url
  end

  private

  def user_params
    params.require(:user).permit User::PERMITTED_PARAMS
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t "users.logged_in_user.flash_not_logged_in"
    redirect_to login_url
  end

  def correct_user
    redirect_to root_url unless current_user? @user
  end

  def admin_user
    redirect_to root_url unless current_user.admin?
  end

  def load_exists_user
    @user = User.find_by id: params[:id]
    return if @user.present?

    flash[:danger] = t "users.show.flash_not_found"
    redirect_to root_url
  end
end
