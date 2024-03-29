class UsersController < ApplicationController

  # before アクション 処理を実行する直前に特定のメソッドを実行する仕組み
  # オプションにindex,edi,destroyとupdateを渡し、onlyとすることで、対象の部分でしか利用できない仕様
  # アクションごとに適用されるので、テストはアクションごとに記載する必要あり
  # followinf,followers追加,
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  
  # 別のユーザーのプロフィールを編集しようとしたらリダイレクト
  before_action :corrent_user, only: [:edit, :update]
  
  # コマンドラインでも削除できなくするように、destroyアクション自体に制御を入れる
  before_action :admin_user,  only: :destroy
  
  def index
    # 全ユーザーが格納された変数(viewで使えるインスタンス変数)
    # @users = User.all 
    # paginateを実装 引数にページを設定
    # @users = User.paginate(page: params[:page])
    # 有効であるユーザーが:idを指定すると各ユーザーのページが表示される
    @users = User.where(activated: true).paginate(page: params[:page])
  end
  
  def show
    @user = User.find(params[:id])
    
    # 必要なマイクロポストのページを引き出す
    @microposts = @user.microposts.paginate(page: params[:page])
    # @userが有効でない場合はリダイレクトを実行しない
    # 同じアクション内でrenderを複数呼び出すとエラーになるため、and return をつけて明示的に処理を終了させる
    redirect_to root_url and return unless @user.activated?
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
      
      # リファクタリング　コントローラからモデルに移動
      # UserMailer.account_activation(@user).deliver_now
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      
      #新規登録したユーザーはログイン済みとする
      # log_in @user
      
      # 新規ユーザーへのウィルカムメッセージ(2度目以降は表示しない),リダイレクトした直後のページに表示される
      # flash[:success] = "Welcome to the Sample App!"
      
      # アカウント有効化において、ユーザーページへの遷移は意味がない
      # redirect_to @user #redirect_to user_url(@user)と同義
    else
      render 'new'
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      # 更新に成功した場合
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      # 更新に失敗した場合 editに戻る
      render 'edit'
    end
  end
  
  # ログインしている必要があるため、before_actionを指定する
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end
  
  # following
  def following
    @title = "Following"
    @user = User.find(params[:id])
    
    @users = @user.following.paginate(page: params[:page])
    # 明治的に呼び出し
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    # 明治的に呼び出し
    render 'show_follow'
  end
  
  # private化してこの中でのみ使えるものとする。
  private
  
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
    
    # beforeアクション
    
    # 正しいユーザーかどうか確認 一致していなかったらルートURLへ
    def corrent_user
      @user = User.find(params[:id])
      # redirect_to(root_url)  unless @user == current_user
      # メソッドを作成し、falseだった場合はルートURLへ
      redirect_to(root_url) unless current_user?(@user)
    end
    
    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
    
end
