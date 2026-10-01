class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]
  before_action :correct_user, only: :destroy

  def create
    # beforeフィルターでログインしていることが前提
    # current_userを元にした関連付けによって生成されたメソッド
    # user_idがデフォルトで入った状態で作成できる
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = 'Micropost created!'
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  # DELETE /microposts/:id
  def destroy
    # ログインしているユーザと作成したユーザーが同じであれば削除して良い
    @micropost.destroy
    flash[:success] = 'Micropost deleted'
    # 元のページへ戻す。なければトップページへとぶ
    redirect_back_or_to(root_url, status: :see_other)
    # # リダイレクト先
    # if request.referrer.nil?
    #   # リファラー（直前に見ていたページ）がnilであれば,デフォルトルートに飛ぶ
    #   redirect_to root_url, status: :see_other
    # else
    #   # リファラーが指す今いるページにリダイレクトする
    #   redirect_to request.referrer, status: :see_other
    # end
  end

  private

  # ストロングパラメータではidは要らない。（currentuserで自動で入るから）contentのみでいい。
  def micropost_params
    params.require(:micropost).permit(:content)
  end

  # 消したい投稿の持ち主が自分でるか
  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    # find_byは見つからないとnilを返す
    redirect_to root_url, status: :see_other if @micropost.nil?
  end
end
