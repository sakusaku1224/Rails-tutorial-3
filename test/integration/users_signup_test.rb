require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test 'invalid signup information' do
    # ユーザーが失敗するテスト
    # サインアップページに行く
    get signup_path
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
  end

  test 'valid signup information' do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: 'Example User',
                                         email: 'user@example.com',
                                         password: 'password',
                                         password_confirmation: 'password' } }
    end
    follow_redirect!
    assert_response :success
    assert_select 'title', 'Example User | Ruby on Rails Tutorial Sample App'
    assert is_logged_in?
  end
end
