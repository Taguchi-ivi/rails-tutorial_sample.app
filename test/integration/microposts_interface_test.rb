require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "micropost interface" do
    
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    
    # ファイル属性が存在することを確認
    assert_select 'input[type=file]'
    
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
    
    # 有効な送信 画像データも送信してみる
    content = "This micropost really ties the room together"
    # ファイルをウップロードする
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content,
                                                   image: image} }
    end
    
    # assert_redirected_to root_url
    # 画像が取り込まれたか
    # 投稿に成功した後にcreateアクション内のマイクロポストにアクセス
    assert assigns(:micropost).image.attached?
    
    follow_redirect!
    assert_match content, response.body
    
    # 投稿を削除する
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    
    # 違うユーザーのプロフィールにアクセス(削除リングがないことを確認)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
    
  end
  
  # サイドバーの合計投稿数のテスト
  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # まだマイクロポストを投稿していないユーザー
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end
  
  
  
  # test "the truth" do
  #   assert true
  # end
end
