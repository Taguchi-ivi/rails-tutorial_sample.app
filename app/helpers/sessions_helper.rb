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
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
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
  
end
