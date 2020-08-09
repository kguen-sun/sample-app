class FollowingController < ApplicationController
  before_action :logged_in_user, :get_user

  def index
    @title = t ".title"
    @users = @user.following.page params[:page]
    render "shared/show_follow"
  end
end
