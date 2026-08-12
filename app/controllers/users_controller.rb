class UsersController < ApplicationController
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
      flash[:success] = 'Welcome to the Sumple App!'
      # リダイレクトを実行するとGETリクエストを送る /users/:id（新規のリクエストを発行する）
      # createでPOSTリクエストを送った処理の途中でGETリクエストを送る
      redirect_to @user
      # redirect_to user_path(@user) #GET /user/:id
      # userのインスタンスを渡すと対応するidを引っ張ってくる
    else
      flash.now[:alrt] = '登録に失敗しました'
      render 'new', status: :unprocessable_entity
    end
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
end
