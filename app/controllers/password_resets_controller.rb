class PasswordResetsController < ApplicationController
  # これまでアクション内に書いていた取得と認証の処理をメソッド化する
  # 今回はeditとupdateアクションの中でもチェックをしないといけないのでDRYでない
  before_action :get_user,   only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    # scope指定すると、password_reset[email]=example@example.com
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    # もしuserがいたら
    # app/models/user.rb
    if @user
      @user.create_reset_digest
      # トークンを生成・保存、ダイジェストを生成・保存
      @user.send_password_reset_email
      # 再設定用のメールを送信する
      flash[:info] = 'Email sent with password reset instructions'
      redirect_to root_url
    else
      flash.now[:danger] = 'Email address not found'
      render 'new', status: :unprocessable_entity
    end
  end

  def edit; end

  # PATCH /password_resets/:id
  def update
    if params[:user][:password].empty?
      # 空文字対策
      @user.errors.add(:password, 'can not be empty')
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params)
      # strong paramatersアクセス権限も持っている
      reset_session
      log_in @user
      flash[:success] = 'Password has been reset.'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

  # strong paramaters
  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # ユーザーオブジェクトを引っ張ってくる
  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか認証する
  # activationされていて、トークンがダイジェストと一致しているかどうかチェックする
  def valid_user
    return if @user && @user.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  # トークンが期限切れかどうか確認する
  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_url
  end
end
