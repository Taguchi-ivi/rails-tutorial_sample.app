require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "login with valid email/invalid password" do
    #ログイン用の画面を表示
    get login_path
    #新しいセッションフォームが正しく表示されたか確認
    assert_template 'sessions/new'
    # 間違ったデータを送信(テストユーザー) passwordのミス
    post login_path,params: { session: { email: @user.email,
                                         password: 'invalid' } }
    # ログインできていないことを確認(パスワードのミス)
    assert_not is_logged_in?
    #新しいセッションフォームが正しく表示されたか確認
    assert_template 'sessions/new'
    # flash(一時的なメッセージ)が存在していることを確認
    assert_not flash.empty?
    #ルート画面homeに遷移
    get root_path
    # 遷移した際にflashが存在しないことを確認
    assert flash.empty?
  end
  
  test "login with valid infomation follew by logout" do
    # ログイン画面を表示
    get login_path
    #  正しいログイン情報を送信(テストユーザー)
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    # ログインしたことを確認
    assert is_logged_in?
    # ユーザーページに移動したことを確認
    assert_redirected_to @user
    # 実際にリダイレクト先に移送
    follow_redirect!
    # users/showが表示されていることを確認
    assert_template 'users/show'
    # ログインのリンクが存在しないことを確認(ログイン済みである為)
    assert_select "a[href=?]", login_path, count: 0
    # ログアウトのリンクが存在していることを確認(ログイン済みである為)
    assert_select "a[href=?]", logout_path
    # ユーザー詳細ページのリンクが存在することを確認(ログイン済みである為)
    assert_select "a[href=?]", user_path(@user)
    # ログアウトを実行(リクエスト)
    delete logout_path
    # ログイン済みでないことを確認
    assert_not is_logged_in?
    # ルートにリダイレクト
    assert_redirected_to root_url
    # 更新：複数タブで開いていた場合を想定して、再度ログアウト
    delete logout_path
    # 実際にリダイレクト先に移動
    follow_redirect!
    # ログインのリンクが存在することを確認(ログアウト済みである為)
    assert_select "a[href=?]", login_path
    # ログアウトのリンクが存在しないことを確認(ログアウト済みである為)
    assert_select "a[href=?]", logout_path,      count: 0
    # ユーザー詳細ページへのリンクが存在しないことを確認(ログアウト済みである為)
    assert_select "a[href=?]", user_path(@user), count: 0  
  end
  
  
  # ログインした際にremember_meが登録されることを確認
  test "login with remembering" do
    log_in_as(@user,remember_me: '1')
    # assert_not_empty cookies[:remember_token]
    # tokenが発行されているか確認
    assert_equal cookies['remember_token'], assigns(:user).remember_token
    
  end
  
  # ログインした際にremember_meを登録しなかった場合に、登録されないことを確認
  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as(@user,remember_me: '1')
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user,remember_me: '0')
    assert_empty cookies[:remember_token]
  end
    
  # test "the truth" do
  #   assert true
  # end
end
