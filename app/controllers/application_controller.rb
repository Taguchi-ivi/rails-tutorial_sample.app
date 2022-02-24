class ApplicationController < ActionController::Base
  
  include SessionsHelper
  
  private
    
    # userコントローラーからこっちへ移動。micropostでも使用するため
    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        # セッションにアクセスしたURL
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url
      end
    end
    
  # def hello
  #   render html:"hello,world!"
  # end
end
