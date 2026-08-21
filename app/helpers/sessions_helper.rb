module SessionsHelper
  def log_in(user)
    session[:user_id] = user.id
    # セッションリプレイ攻撃から保護する
    # 詳しくは https://techracho.bpsinc.jp/hachi8833/2023_06_02/130443 を参照
    session[:session_token] = user.session_token
  end

  # 永続的セッションのためにユーザーをクッキーに記憶する
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def current_user
    if (user_id = session[:user_id])
      user = User.find_by(id: user_id)
      @current_user = user if user && session[:session_token] == user.session_token
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  # 記憶トークンcookieに対応するユーザーを返す
  # def current_user
  #   # sessionの中のuser_idをuser_id変数に代入して、その中身があるのでれば！
  #   # if (user_id = session[:user_id])
  #   #   # 1回目はDBから参照するが、２回目以降はそれを使用する
  #   #   @current_user ||= User.find_by(id: user_id)
  #   user = User.find_by(id: user_id)
  #   if user && session[:session_token] == user.session_token
  #     @current_user = user
  #   end

  #   # セッションが切れているが、クッキーの中にuser_idが入っている！
  #   elsif (user_id = cookies.encrypted[:user_id])
  #     # raise # テストがパスすれば、この部分がテストされていないことがわかる
  #     # user_idを引っ張ってきて、userに代入する
  #     user = User.find_by(id: user_id)
  #     # クッキーの中のremember_tokenを検証する？
  #     if user && user.authenticated?(cookies[:remember_token])
  #       log_in user
  #       @current_user = user
  #     end
  #   end
  # end
  # user が存在していて、なおかつ、その user が current_user と同じなら true　nilガード
  def current_user?(user)
    user && user == current_user
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

  # アクセスしようとしたURLを保存する
  # getリクエストかどうか確認する　GETのみ保存する
  def store_location
    session[:forwarding_url] = request.original_url if request.get?
  end
end
