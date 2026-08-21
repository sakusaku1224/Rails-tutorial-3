class UsersController < ApplicationController
  # 認可　ログインしていますか？
  before_action :logged_in_user, only: %i[index edit update destroy]
  # 本人ですか？current_userはlog_inしている前提
  before_action :correct_user, only: %i[edit update]
  # 管理者なら削除できる
  before_action :admin_user, only: :destroy

  # GET /users
  def index
    @users = User.paginate(page: params[:page])
  end

  # GET /users/:id
  def show
    @user = User.find(params[:id])
    # => app/views/users/show.html.erb
  end

  # GET /users/new
  def new
    @user = User.new
    # => app/views/users/new.html.erb
  end

  # POSt /users/create
  def create
    @user = User.new(user_params)
    if @user.save
      reset_session
      log_in @user
      flash[:success] = 'Welcome to the Sumple App!'
      # リダイレクトを実行するとGETリクエストを送る /users/:id（新規のリクエストを発行する）
      # createでPOSTリクエストを送った処理の途中でGETリクエストを送る
      redirect_to @user
      # redirect_to user_path(@user) #GET /user/:id
      # userのインスタンスを渡すと対応するidを引っ張ってくる
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = 'Profile updated'
      redirect_to @user
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = 'User deleted'
    redirect_to users_path, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :email,
      :password,
      :password_confirmation
    )
  end

  # ログイン済みユーザーかどうか確認
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'Please log in.'
    redirect_to login_url, status: :see_other
  end

  # 正しいユーザーかどうか確認
  def correct_user
    @user = User.find(params[:id])
    # 今のユーザーとcurrent_user(現在ログインしているUserオブジェクト)は同じですか？
    # current_userとcorrect_userはnilを返し得るのでヘルパーでガード
    redirect_to(root_url, status: :see_other) unless current_user?(@user)
  end

  # 管理者かどうか確認
  def admin_user
    redirect_to(root_url, status: :see_other) unless current_user.admin?
  end
end
