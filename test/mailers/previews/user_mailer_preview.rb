# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/account_activation
  def account_activation
    
    # 実際の有効なUserオブジェクトと渡す必要があり
    user = User.first
    user.activation_token = User.new_token
    # UserMailer.account_activation
    UserMailer.account_activation(user)
    
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_reset
  def password_reset
    UserMailer.password_reset
  end

end
