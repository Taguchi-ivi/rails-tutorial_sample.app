class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # if user && user.authenticate(params[:session][:password])
    # 省略した形に変更
    if user&.authenticate(params[:session][:password])
      # 認証OKの場合 --ログイン後にユーザーページにリダイレクトする
      
      #cookieにログイン（関数） 
      log_in user
      # リダイレクト先を指定（プロフィールページに遷移）
      redirect_to user
      
    else
      # 認証NGの場合 --エラーメッセージを作成する
      # flash[:danger] = "Invalid email/password combination" #この状態のままだと一回入るとずっとエラーメッセージが表示されてしまう
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
    
  end
  
  def destroy
    log_out
    redirect_to root_url
  end
end
