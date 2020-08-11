class StaticPagesController < ApplicationController
  def home
    return unless logged_in?

    @user = current_user
    @micropost = current_user.microposts.build
    @feed_items = current_user.feed.order_by_created_at_desc.page params[:page]
  end

  def help; end

  def about; end

  def contact; end
end
