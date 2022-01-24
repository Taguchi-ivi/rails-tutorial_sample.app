class SessionsController < ApplicationController
  def new
  end
  
  def create
    ## userをインスタンス変数に変更して、remember_tokenが発行されていることを確認する
    # user = User.find_by(email: params[:session][:email].downcase)
    @user = User.find_by(email: params[:session][:email].downcase)
    # if user && user.authenticate(params[:session][:password])
    # 省略した形に変更
    
    # if user&.authenticate(params[:session][:password])
    if @user&.authenticate(params[:session][:password])
      # 認証OKの場合 --ログイン後にユーザーページにリダイレクトする
      
      #cookieにログイン（関数） 
      # log_in user
      log_in @user
      
      #永続cookieを設定
      # remember user
      # chekboxがオン(1)なら記憶ダイジェストを、オフ(0)なら記憶ダイジェストを破棄する　それを1行で指定
      # params[:session][:remember_me] == '1' ? remember(user) :forget(user)
      params[:session][:remember_me] == '1' ? remember(@user) :forget(@user)
      # リダイレクト先を指定（プロフィールページに遷移）
      # redirect_to user
      redirect_to @user
      
    else
      # 認証NGの場合 --エラーメッセージを作成する
      # flash[:danger] = "Invalid email/password combination" #この状態のままだと一回入るとずっとエラーメッセージが表示されてしまう
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
    
  end
  
  def destroy
    # logged_inがtrueの場合のみ実行 ログインしていたら
    log_out if logged_in?
    redirect_to root_url
  end
end
