require 'test_helper'

class UsersSignup < ActionDispatch::IntegrationTest
  def setup
    # メール配信をクリアする
    # 配列をクリアすることで、他のメール配信関連テストが壊れないようにする
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    # ユーザーが失敗するテスト
    # サインアップページに行く
    # get signup_path
    # 以下のコードを実行してもUser.countの数値が変わらない。（適切なデータが入力されていないと保存されない）
    assert_no_difference 'User.count' do
      # 直接postメソッドを送る。その時にparamsに何を渡すのか指定をする
      post users_path, params: { user: { name: '',
                                         email: 'user@invalid',
                                         password: 'foo',
                                         password_confirmation: 'bar' } }
    end
    # 422のエラーコードをブラウザに返す
    assert_response :unprocessable_entity
    assert_select 'title', 'Sign up | Ruby on Rails Tutorial Sample App'
    # assert_select 'div#error_explanation'
    # assert_select 'div.field_with_errors'
  end

  test 'valid signup information with account activation' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User',
                                         email: 'user@example.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
    end
    # 配信されたメッセージが１件かどうか確認する
    # ここまでの処理を終えていたら、メールが１つは配信されてますよね？
    assert_equal 1, ActionMailer::Base.deliveries.size
    # follow_redirect!
    # assert_response :success
    # assert_select 'title', 'Example User | Ruby on Rails Tutorial Sample App'
    # assert is_logged_in?
  end
end

class AccountActivationTest < UsersSignup
  def setup
    super
    post users_path, params: { user: { name: 'Example User',
                                       email: 'user@example.com',
                                       password: 'password',
                                       password_confirmation: 'password' } }
    # controller.view_assignsコントローラのインスタンス変数を使用する
    @user = controller.view_assigns['user']
  end

  test 'should not be activated' do
    assert_not @user.activated?
  end

  test 'should not be able to log in before account activation' do
    log_in_as(@user)
    assert_not is_logged_in?
  end

  test 'should not be able to log in with invalid activation token' do
    get edit_account_activation_path('invalid token', email: @user.email)
    assert_not is_logged_in?
  end

  test 'should not be able to log in with invalid email' do
    get edit_account_activation_path(@user.activation_token, email: 'wrong')
    assert_not is_logged_in?
  end

  test 'should log in successfully with valid activation token and email' do
    get edit_account_activation_path(@user.activation_token, email: @user.email)
    assert @user.reload.activated?
    follow_redirect!
    assert_response :success
    assert_select 'title', 'Example User | Ruby on Rails Tutorial Sample App'
    assert is_logged_in?
  end
end
# class AssountActivationTest < UsersSignup
#   def setup
#     super
#     post users_path, params: { user: { name: 'Example User',
#                                        email: 'user@example.com',
#                                        password: 'password',
#                                        password_confirmation: 'password' } }
#     # controller.view_assignsを使うことで、対応するアクションでインスタンス変数にアクセスできる
#     @user = controller.view_assigns['user']
#   end

#   test 'should not be activated' do
#     # 有効化されていないユーザーではない
#     assert_not @user.activated?
#   end

#   test 'should not be able to log in before accout activation' do
#     # 有効化される前のアカウントはログインできない
#     log_in_as(@user)
#     assert_not is_logged_in?
#   end

#   test 'should not be able to log in with invalid activation token' do
#     # 無効なactivationトークンではログインできない
#     get edit_account_activation_path('invalid token', email: @user.email)
#     assert_not is_logged_in?
#   end

#   test 'should not be able to log in with invalid email' do
#     # 無効なemailではログインできない
#     get edit_account_activation_path(@user.activation_token, email: @user.email)
#     assert_not is_logged_in?
#   end

#   test 'should log in successfully with activation token and email' do
#     # 有効なトークンとメールアドレスであればログインできる
#     get edit_account_activation_path(@user.activation_token, email: @user.email)
#     assert @user.reload.activate?
#     follow_redirect!
#     assert_response :success
#     assert_select 'title', 'Example User | Ruby on Rails Tutorial Sample App'
#     assert is_logged_in?
#   end
# end
