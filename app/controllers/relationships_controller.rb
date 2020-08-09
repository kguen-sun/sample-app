class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find_by id: params[:followed_id]

    if @user
      current_user.follow @user
      respond
    else
      redirect_to_root
    end
  end

  def destroy
    @user = Relationship.find_by(id: params[:id]).followed

    if @user
      current_user.unfollow @user
      respond
    else
      redirect_to_root
    end
  end

  private

  def respond
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def redirect_to_root
    flash[:danger] = t "users.get_user.flash_not_found"
    redirect_to root_url
  end
end
