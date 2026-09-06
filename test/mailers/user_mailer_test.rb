require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test 'account_activation' do
    user = users(:michael)
    # トークンを生成し、仮想属性に代入、メーラーを呼び出し、mailオブジェクトが返ってくるのでチェックする
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)

    # 宛先、エスケープ、エンコーディングされているかどうか
    assert_equal 'Account activation', mail.subject
    assert_equal [user.email], mail.to
    assert_equal ['user@realdomain.com'], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

end
