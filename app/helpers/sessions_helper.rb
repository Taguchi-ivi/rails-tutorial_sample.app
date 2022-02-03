module SessionsHelper
  
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end
  
  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end
  
  # 更新：記憶トークンcookieに対応するユーザを返す
  # 現在ログイン中のユーザーを返す(いる場合)
  def current_user
    # sessionのユーザーが存在すれば変数に格納 =だけなので比較文ではなく代入しているだけ
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: session[:user_id])
    
    # cookieに存在すれば変数に格納
    elsif (user_id = cookies.signed[:user_id])
      # raise         # テストがパスすれば、この部分がテストされていない事がわかる
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # 渡されたユーザーがカレントユーザーであればtrueを返す
  # userがnilだった場合,userとcurrent_userが一致していない場合はfalseを返す
  def current_user?(user)
    user && user == current_user
  end
  
  # ユーザーがログインしていればtrue その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end
  
  
  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end
  
  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
  
  # 記憶したURL(もしくはデフォルト値)にリダイレクト
  
  def redirect_back_or(default)
    # nilではなかったらsessionの場所へ、それ以外はdefaultへ
    redirect_to(session[:forwarding_url] || default)
    # 転送用のuRLを削除 redirectを先にしてもreturnやメソッドの最終行が呼び出されない限り、最後まで処理が走る
    session.delete(:forwarding_url)
  end
  
  # アクセスしようとしたURLを覚えておく
  # request.original_urlでリクエスト先を取得できる
  def store_location
    session[:forwarding_url] = request.original_url if request.get?  # getリクエストの時のみ！！
  end
  
end
