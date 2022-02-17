class PasswordResetsController < ApplicationController
  
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]
  
  def new
  end
  
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
      
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  
  end

  def edit
  end
  
  def update
    
    # 新しいパスワードがから文字列ではないことを確認
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    
    # 新しいパスワードが正しいことを確認 
    elsif @user.update(user_params)
      log_in @user
      # @userの:reset_digestの値をnilに更新して保存
      # 2時間以内であればさらにパスワードを更新できてしまうので、reset_digestの値をnilにしておく
      @user.update_attribute(:reset_digest,nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    
    # 無効なパスワードは失敗させる editへ遷移
    else
      render 'edit'
    end
  end
  
  # 下記はここでのみ使用可能な状態とする
  private
    
    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
    
    
    # beforeフィルタ
    
    # 対象者を特定する
    def get_user
      @user = User.find_by(email: params[:email])
    end
  
    # 正しいユーザーかどうか判定
    # ユーザーが存在するか && 有効化されているか && 認証済みであること を確認
    def valid_user
      # falseであればルートurlに飛ぶ仕様
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end
    
    # トークンが期限切れかどうか確認
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
  
  
  
end
