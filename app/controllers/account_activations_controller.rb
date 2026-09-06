class AccountActivationsController < ApplicationController
  # GET/account_activations/:id/edit
  def edit
    # emailとtokenを引っ張ってくる
    user = User.find_by(email: params[:email])
    # activatedされていないか？既にクリックされていない？活性化されていないか？
    if user && !user.activated? && user.authenticated?(:activation, params[:id]) # 中身はトークン
      # user.update_attribute(:activated, true)
      # user.update_attribute(:activated_at, Time.zone.now)
      user.activate
      log_in user
      flash[:success] = 'Account activated!'
      redirect_to user
    else
      flash[:danger] = 'Invalid activation link'
      redirect_to root_url
    end
  end
end
