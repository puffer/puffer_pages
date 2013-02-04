PufferPages::Engine.routes.draw do
  match '(*path)' => 'pages#index', :as => 'puffer_page'
end
