require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  
  # fixtureでuser変数を定義して、rememberメソッドで記憶
  def setup
    @user = users(:michael)
    remember(@user)
  end
  
  # ユーザーの記憶ダイジェストと記憶トークンが一致することを確認
  # assert_equal = 第一引数と第二引数の値が一致していることを確認する
  # assert_equal = 第一引数が期待する値,第二引数が実際の値である必要あり
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end
  
  # ユーザーの記憶ダイジェストが記憶トークンと正しく対応していない場合,nilになることを確認
  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
  
end