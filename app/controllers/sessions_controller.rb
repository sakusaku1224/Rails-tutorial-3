class SessionsController < ApplicationController
  def new
    # @session = Session.new :can't use!
    # scope: :session + url: login_path を使用する
  end

  # POST /login
  def create
    # userオブジェクトが存在し、かつパスワードが正しいかを確認
    user = User.find_by(email: params[:session][:email].downcase)
    if user&.authenticate(params[:session][:password])
      # Success @userオブジェクトが返ってくる
      session[:user_id] = user.id
      # redirect_to user_path(@user)
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      redirect_to user
    else
      flash.now[:danger] = 'Invalid email/password'
      render 'new', status: :unprocessable_entity
      # render 'new'はnewアクションを呼び出すのではなく、new.html.erbを再描画
      # flashは次のリクエストが来たら消える。render new (0回目のリクエスト)
    end
  end

  def destroy
    log_out if logged_in?
    # 303 See Otherステータスを指定することで、DELETEリクエスト後のリダイレクトが正しく振る舞うようにする
    redirect_to root_path, status: :see_other
  end
end
