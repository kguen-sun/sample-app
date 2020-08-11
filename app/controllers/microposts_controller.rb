class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy
  before_action :build_micropost, only: :create

  def create
    if @micropost.save
      flash[:success] = t ".flash_created"
      redirect_to root_url
    else
      @user = current_user
      @feed_items = current_user.feed
                                .order_by_created_at_desc
                                .page params[:page]
      render "static_pages/home"
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = t ".flash_destroyed"
    redirect_back fallback_location: root_url
  end

  private

  def build_micropost
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach params[:micropost][:image]
  end

  def micropost_params
    params.require(:micropost).permit Micropost::PERMITTED_PARAMS
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:error] = t ".flash_wrong_user"
  end
end
