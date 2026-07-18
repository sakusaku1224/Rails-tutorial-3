Rails.application.routes.draw do
  root 'static_pages#home'

  # URLとアクション２つの意味を持つ
  get 'static_pages/home'
  get 'static_pages/help'
  get 'static_pages/about'
end
