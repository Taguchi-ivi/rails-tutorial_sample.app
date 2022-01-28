require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  # 編集データにエラーが存在した場合を想定
  test "unsuccessful edit" do
    # ログイン状態としないとエラーになる(認可されているか確認しているため)
    log_in_as(@user)
    # 画面遷移
    get edit_user_path(@user)
    #編集画面が表示されていることを確認 
    assert_template 'users/edit'
    # 無効となる編集データを送信
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invaild",
                                              password: "foo",
                                              password_confirmation: "bar" } }
    # エラーとなり再度編集画面が表示されることを確認
    assert_template 'users/edit'
    # エラーが表示されることを確認 [The form contains 4 errors.]と表示されることを確認する
    assert_select "div.alert","The form contains 4 errors."
  end
  
  # 編集データが正しく処理されることを確認
  test "successful edit with friendly forwarding" do
    # 編集ページにアクセス
    get edit_user_path(@user)
    # session[:forwarding_url]とedit_user_url(@user)が等しい時にtrue
    assert_equal session[:forwarding_url],edit_user_url(@user)
    # ログイン状態としないとエラーになる(認可されているか確認しているため)
    log_in_as(@user)
    # 編集ページにリダイレクトされていることを確認
    # assert_redirected_to edit_user_url(@user)
    
    # forwarding_urlがnilだったらOK
    assert_nil session[:forwarding_url]
    
    # 画面遷移
    # get edit_user_path(@user)
    # 編集画面が表示されることを確認
    # assert_template 'users/edit'
    #定義
    name = "Foo Bar"
    email = "foo@bar.com"
    # 編集データ(正しい)を送信
    patch user_path(@user),params: { user: { name: name,
                                             email: email,
                                             password: "",
                                             password_confirmation: "" } }
    # flashメッセージが空でないかどうか
    # update完了のメッセージ
    assert_not flash.empty?
    # プロフィール画面に遷移されるかどうか
    assert_redirected_to @user
    # 値を再取得
    @user.reload
    # 値が一致しているかを確認 assert_equal=第一引数と第二引数が一致しているか確認
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
  
  
  # test "the truth" do
  #   assert true
  # end
end
