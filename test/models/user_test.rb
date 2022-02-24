require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  def setup #各テストが実行される直前で実行される
    # @user = User.new(name: "Example User", email:"user@example.com")
    # ハッシュ作成によりpassword,password_confirmationが必要になった
    @user = User.new(name: "Example User", email:"user@example.com",
                     password: "foobar"  , password_confirmation: "foobar")
  end
  
  #有効か確認
  test "should be valid" do
    #有効であればtrue + @userが有効か確認
    assert @user.valid?
  end
  
  ## 無効性のテストが多い？？ ##
  
  #空欄だった場合にエラーになることを確認
  test "name should be present" do
    @user.name = ""
    #空白の@user.nameが有効か→falseである　←この時成功するテスト
    
    assert_not @user.valid?
  end
  
  #空欄だった場合にエラーになることを確認
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  #51文字以上がエラーになることを確認
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  #255文字以上がエラーになることを確認
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  #emailのアドレスを有効性確認
  test "eamil validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn ]
    
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?,"#{invalid_address.inspect} should be invalid"
    end
  end
  
  #まず重複したメールアドレスからテスト
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase #大文字小文字関係なく全て確認する
    @user.save
    assert_not duplicate_user.valid?
  end
  
  #メールアドレスの小文字化に対するテスト
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase,@user.reload.email
  end
  
  #パスワードがブランクだった場合にエラーになることを確認 + 空欄6でもエラーになることを確認
  #多重代入 = 同じ値を代入したい変数を"="で繋げて同じ値を代入すること
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6 
    assert_not @user.valid?
  end
  
  # パスワードがブランク5文字だったらエラーになることを確認
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  # 記憶ダイジェストを持たないユーザーを用意してメソッドで確認 他のブラウザで記憶ダイジェストを持たない状態となった場合の確認
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  # userが削除されたらmicropostsも削除されること
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  
end
