class AccountActivationsController < ApplicationController
  
  def edit
    user = User.find_by(email: params[:email])
    # ユーザーが存在する　かつまだ有効化されていない　かつトークンとダイジェストの値が一致していたら
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # アカウントの有効化を実施
      # リファクタリング コントローラからモデルに移動
      # user.update_attribute(:activated, true)
      # user.update_attribute(:activated_at, Time.zone.now)
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
      
    else
      # アカウントの有効化ができなかった場合
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
      
    end
  end

end
