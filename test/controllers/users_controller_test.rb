require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end
  
  test "should get new" do
    # get users_new_url
    get signup_path
    assert_response :success
  end
  
  # indexはログインしたユーザーのみとするため、ログインしていなかったらログイン画面へリダイレクト
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end
  
  # アクションごとに設定
  
  # リクエストを送り、flashにメッセージが代入されたか,ログイン画面にリダイレクトされたか
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    # assert_not flash.empty?
    # フラッシュがemptyになる。ルートURLに移動するから？
    assert flash.empty?
    # すでにログイン済みのユーザーが対象となるため、ログインページではなく、ルートURLになっている
    assert_redirected_to root_url
  end
  
  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    # フラッシュがemptyになる。ルートURLに移動するから？
    assert flash.empty?
    # すでにログイン済みのユーザーが対象となるため、ログインページではなく、ルートURLになっている
    assert_redirected_to root_url
  end
  
  # URLからadminを変更できないように、変更できないことを確認する
  # 下記10.4.1の演習。期待値通りにエラーにならなったため、一度コメントアウト
  test "should not allow the admin attribute to be edited via the web" do
    # ログイン
    # log_in_as(@other_user)
    # adminがfalseであることを確認
    # assert_not @other_user.admin?
    # adminをtrueにしてデータを送信(patchをリクエスト)
    # patch user_path(@other_user), params: {
    #                                 user: { password:              "password",
    #                                         password_confirmation: "password",
    #                                         admin: true } }
    # 再度読み込み、adminがfalseであることを確認
    # assert_not @other_user.reload.admin?
  end
  
  # ログインしていないユーザーがdeleteリクエストした場合、ログイン画面に遷移すること
  test "should redirect destroy when not logged in" do
    # ユーザー数が変化していないことも確認（削除されていないことの確認）
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to  login_url
  end

  # ログインしていて、管理者ではないユーザーがdeleteリクエストをした場合、ホーム画面に遷移すること
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    # ユーザー数が変化していないことも確認（削除されていないことの確認）
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end
  
  # フォローページへの認可 ログインしていない状態
  test "should redirect following when not logged in" do
    # /users/@userのid/followingへgetのリクエスト
    get following_user_path(@user)
    assert_redirected_to login_url
  end
  
  test "should redirect followers when not logged in" do
    # /users/@userのid/followersへgetのリクエスト
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
  
  
  
  
  
  
end
