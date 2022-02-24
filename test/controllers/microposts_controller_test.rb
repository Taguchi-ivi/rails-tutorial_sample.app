require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  
  def setup
    @micropost = microposts(:orange)
  end
  
  # 新規作成
  # ログインしていないユーザー、投稿数が変化していないこと。ログイン画面に遷移すること
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    
    assert_redirected_to login_url
    
  end
  
  # 削除
  # ログインしていないユーザー、投稿数が変化していないこと。ログイン画面に遷移すること
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end
  
  # 自分以外のユーザーが削除しようとしたらルートurlに飛ばされること
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))
    micropost = microposts(:ants)
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url
    
  end
  
  # test "the truth" do
  #   assert true
  # end
end
