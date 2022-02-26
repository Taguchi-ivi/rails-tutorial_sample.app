require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  
  # ログイン済みか確認し、ログインしていない場合はログインページにリダイレクト
  # リダイレクトされるのでRelationshipのカウントが変わっていないことを確認
  
  # フォロー
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end
  
  # フォロー解除
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
  
  # test "the truth" do
  #   assert true
  # end
end
