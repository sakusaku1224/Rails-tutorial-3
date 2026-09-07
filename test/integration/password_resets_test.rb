require 'test_helper'

class PasswordResets < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class ForgotPasswordFormTest < PasswordResets
  test 'password reset path' do
    # forgotpasswaordページに正しくアクセスできるかどうか
    get new_password_reset_path
    assert_response :success
    assert_select 'title', 'Forgot password | Ruby on Rails Tutorial Sample App'
    # <input type="email" name="password_reset[email]">というフォームがあるかどうか
    assert_select 'input[name=?]', 'password_reset[email]'
  end

  test 'reset path with invalid email' do
    # 無効なemail（空）のときは、遷移せずにflashメッセージが出る
    post password_resets_path, params: { password_reset: { email: '' } }
    assert_response :unprocessable_entity
    assert_not flash.empty?
    assert_select 'title', 'Forgot password | Ruby on Rails Tutorial Sample App'
  end
end

class PasswordResetForm < PasswordResets
  def setup
    super
    @user = users(:michael)
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = controller.view_assigns['user']
  end
end

class PasswordFormTest < PasswordResetForm
  test 'reset with valid email' do
    # 有効なメールアドレスでパスワードリセットをリクエストしたとき」
    # 再発行リクエストを送ると、再発行用のダイジェストが更新される。一回めならばnilから値が入ってる！
    assert_not_equal @user.reset_digest, @reset_user.reset_digest
    # メールが１通送信された
    assert_equal 1, ActionMailer::Base.deliveries.size
    # フラッシュメッセージが表示査定る
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  test 'reset with wrong email' do
    # emailがURLに含まれていないとトップページへ戻すか？
    get edit_password_reset_path(@reset_user.reset_token, email: '')
    assert_redirected_to root_url
  end

  test 'reset with inactive user' do
  # まだメールでの本登録（有効化）が終わっていないユーザー
    # toggle!というメソッドは、activatedの値を逆（trueからfalse、またはfalseからtrue）に切り替えます。
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_redirected_to root_url
  end

  test 'reset with right email but wrong token' do
  # 有効なメールアドレスだが、トークンがURLにない
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test 'reset with right email and right token' do
  # 有効なメールアドレスとトークンがあれば再設定フォームのページに遷移する
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_response :success
    assert_select 'title', 'Reset password | Ruby on Rails Tutorial Sample App'
    # [type=hidden]フィールドの中のvalueの値が@reset_user.emailと一致するかどうか
    assert_select 'input[name=email][type=hidden][value=?]', @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm
  test 'update with invalid password and confirmation' do
  # 確認用のパスワードが異なる場合はエラーが出る
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'barquux' } }
    # assert_select 'div#error_explanation'
  end

  test 'update with empty password' do
  # 更新用のパスワードが空だとエラーが出る
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: '',
                            password_confirmation: '' } }
    # assert_select 'div#error_explanation'
  end

  test 'update with valid password and confirmation' do
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password: 'foobaz',
                            password_confirmation: 'foobaz' } }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to @reset_user
  end
end
