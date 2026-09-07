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

  # @user.send_password_reset_email
  # UserMailer.password_reset(self).deliver_now
  def password_reset(user)
    @user = user
    mail to: user.email, subject: 'Password reset'
  end
end
