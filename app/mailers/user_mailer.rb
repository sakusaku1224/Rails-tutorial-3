class UserMailer < ApplicationMailer
  # コントローラのアクションと違ってメソッドに近い
  # 引数や戻り値を持つ
  def account_activation(user)
    @user = user
    mail to: user.email,
         subject: 'Account activation'
    # => return: mail object
    #    email:  mail.deliver
  end

  def password_reset
    @greeting = 'Hi'

    mail to: 'to@example.org'
  end
end
