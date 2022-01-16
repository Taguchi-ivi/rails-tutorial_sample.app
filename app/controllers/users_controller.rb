class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    #debugger #デバッグの情報をターミナルに出力する(users/1にアクセスすると出力させる) & コンソールとしてターミナルで値を取得できたりする
  end
  
  def new
    @user = User.new
    # debugger
  end
  
  def create
    # 脆弱性の問題で下記コードはNG 全てのuser情報を渡してしまうため、admin属性に1をするだけで管理者権限を乗っ取られるため。
    # @user = User.new(params[:user])
    @user = User.new(user_params)
    if @user.save
      ## 保存の成功の際はここに
      
      # 新規ユーザーへのウィルカムメッセージ(2度目以降は表示しない),リダイレクトした直後のページに表示される
      flash[:success] = "Welcome to the Sample App!"
      
      redirect_to @user #redirect_to user_url(@user)と同義
    else
      render 'new'
    end
  end
  
  # private化してこの中でのみ使えるものとする。
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    
end
