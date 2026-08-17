module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
  end

  # 永続的セッションのためにユーザーをクッキーに記憶する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 記憶トークンcookieに対応するユーザーを返す
  def current_user
    # sessionの中のuser_idをuser_id変数に代入して、その中身があるのでれば！
    if (user_id = session[:user_id])
      # 1回目はDBから参照するが、２回目以降はそれを使用する
      @current_user ||= User.find_by(id: user_id)

    # セッションが切れているが、クッキーの中にuser_idが入っている！
    elsif (user_id = cookies.encrypted[:user_id])
      # raise # テストがパスすれば、この部分がテストされていないことがわかる
      # user_idを引っ張ってきて、userに代入する
      user = User.find_by(id: user_id)
      # クッキーの中のremember_tokenを検証する？
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    reset_session
    @current_user = nil # 安全のため
  end
end
