Rails.application.routes.draw do
  # get 'users/new'
  # root 'application#hello'
  root 'static_pages#home'
  
    # 名前付きパスは変数名を変更できる to:00, as:00
  # get '/help',    to: 'static_pages#help',as:'helf'
  get '/help',    to: 'static_pages#help'
  get '/about',   to: 'static_pages#about'
  get '/contact', to: 'static_pages#contact'
  
  # user
  get '/signup',   to: 'users#new'
  
  #get 'static_pages/home'
  #get 'static_pages/help'
  #get 'static_pages/about'
  #get 'static_pages/contact'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  
end
