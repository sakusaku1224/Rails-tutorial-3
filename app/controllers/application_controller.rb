class ApplicationController < ActionController::Base
  # 他のコントローラで使用できると便利なメソッドを定義するために、ApplicationControllerに記述する
  # 他のコントローラで使用できるようにするために、helper_methodを使用する
  include SessionsHelper

  private

  # ユーザーのログインを確認する
  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = 'Please log in.'
    redirect_to login_url, status: :see_other
  end
end
