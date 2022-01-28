require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  
  def setup
    @admin = users(:michael)
    @non_admin = users(:archer)
  end
  
  # paginateクラスを持ったdivが最初のページにユーザーがいることを確認
  test "index as admin includinf pagination and delete links"  do
    # ログイン
    log_in_as(@admin)
    # ユーザーズのパスへ
    get users_path
    # 正しく表示されているか確認
    assert_template 'users/index'
    # divタグの中にpatinateがあるか確認 上下に二つあることを確認するため、count:2
    assert_select 'div.pagination', count:2
    # 1ページ目を変数に格納
    first_page_of_users = User.paginate(page: 1)
    # 要素分まわす
    first_page_of_users.each do |user|
      # リンクが正しく設定されていることを確認
      assert_select 'a[href=?]', user_path(user), text: user.name
      # 一致していなかったら(ユーザーが管理者ではなかったら)、処理をスキップ
      unless user == @admin
        # deleteのリンクが存在することを確認
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # 一件削除できることを確認 件数が-1されることを確認
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    # paginateの1ページ目にユーザーが存在するか。またリンク先がユーザーになっていること,テキストはuser.nameであることを確認
    # User.paginate(page:1).each do |user|
    #   assert_select 'a[href=?]', user_path(user), text: user.name
    # end
  end
  
  test "index as non_admin" do
    # ログイン
    log_in_as(@non_admin)
    # ユーザーズ画面へ
    get users_path
    # 管理者ではないユーザーは、deleteリンクが一件もないことを確認
    assert_select 'a', text: 'delete', count:0
    
  end
  
  
  # test "the truth" do
  #   assert true
  # end
end
