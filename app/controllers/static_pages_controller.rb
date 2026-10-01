class StaticPagesController < ApplicationController
  def home
    # ビューで表示するために定義する
    # current_userを呼び出せるのはログインしている場合のみ
    return unless logged_in?

    @micropost  = current_user.microposts.build
    @feed_items = current_user.feed.paginate(page: params[:page], per_page: 10)
  end

  def help; end

  def about; end

  def contact; end
end
