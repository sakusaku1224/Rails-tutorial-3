require 'test_helper'

class UsersLogin < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin
  test 'login path' do
    get login_path
    assert_response :success
    assert_select 'title', 'Log in | Ruby on Rails Tutorial Sample App'
  end

  test 'login with valid email/invalid password' do
    post login_path, params: { session: { email: @user.email,
                                          password: 'invalid' } }
    assert_not is_logged_in?
    assert_response :unprocessable_entity
    assert_select 'title', 'Log in | Ruby on Rails Tutorial Sample App'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
end

class ValidLogin < UsersLogin
  def setup
    # 多分@user = users(:michael)が入る
    super
    post login_path, params: { session: { email: @user.email,
                                          password: 'password' } }
  end
end

class ValidLoginTest < ValidLogin
  test 'valid login' do
    assert is_logged_in?
    assert_redirected_to @user
  end

  test 'redirect after login' do
    follow_redirect!
    assert_response :success
    assert_select 'title', "#{@user.name} | Ruby on Rails Tutorial Sample App"
    assert_select 'a[href=?]', login_path, count: 0
    assert_select 'a[href=?]', logout_path
    assert_select 'a[href=?]', user_path(@user)
  end
end

class Logout < ValidLogin
  def setup
    super
    delete logout_path
  end
end

class LogoutTest < Logout
  test 'successful logout' do
    assert_not is_logged_in?
    assert_response :see_other
    assert_redirected_to root_url
  end

  test 'redirect after logout' do
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    follow_redirect!
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', logout_path,      count: 0
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  test 'should still work after logout in second window' do
    delete logout_path
    assert_redirected_to root_url
  end
  test 'authenticated? should return false for a user with nil digest' do
    assert_not @user.authenticated?('')
  end

  # リメンバーミーのテスト
  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user, remember_me: '0')
    # クッキーは空になる
    assert_empty cookies[:remember_token]
  end
end

# class UsersLoginTest < ActionDispatch::IntegrationTest
#   def setup
#     @user = users(:michael)
#   end

#   test 'login with valid email/invalid password' do
#     get login_path
#     assert_response :success
#     assert_select 'title', 'Log in | Ruby on Rails Tutorial Sample App'
#     post login_path, params: { session: { email: @user.email,
#                                           password: 'invalid' } }
#     assert_not is_logged_in?
#     assert_select 'title', 'Log in | Ruby on Rails Tutorial Sample App'
#     assert_not flash.empty?
#     get root_path
#     assert flash.empty?
#   end

#   # ログイン成功した後にログアウトする
#   test 'login with valid information followed by logout"' do
#     post login_path, params: { session: { email: @user.email,
#                                           password: 'password' } }
#     assert is_logged_in?
#     assert_redirected_to @user
#     follow_redirect!
#     assert_response :success
#     assert_select 'title', "#{@user.name} | Ruby on Rails Tutorial Sample App"
#     assert_select 'a[href=?]', login_path, count: 0
#     assert_select 'a[href=?]', logout_path
#     assert_select 'a[href=?]', user_path(@user)
#     # ログアウトするストーリー
#     delete logout_path
#     assert_not is_logged_in?
#     assert_response :see_other
#     assert_redirected_to root_url
#     follow_redirect!
#     assert_select 'a[href=?]', login_path
#     assert_select 'a[href=?]', logout_path,      count: 0
#     assert_select 'a[href=?]', user_path(@user), count: 0
#   end
#   test 'login with invalid information' do
#     # ユーザーが失敗するテスト
#     # ログインページに行く
#     get login_path
#     assert_response :success
#     assert_select 'title', 'Log in | Ruby on Rails Tutorial Sample App'
#     post login_path, params: { session: { email: '', password: '' } }
#     assert_response :unprocessable_entity
#     assert_select 'title', 'Log in | Ruby on Rails Tutorial Sample App'
#     # フラッシュメッセージが表示されることを確認
#     assert_not flash.empty?
#     get root_path
#     # フラッシュメッセージが消えていることを確認
#     assert flash.empty?
#   end
# end
