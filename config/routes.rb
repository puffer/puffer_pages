Rails.application.routes.draw do

  namespace :admin do
    resources :pages
    resources :layouts
    resources :snippets
  end

end
