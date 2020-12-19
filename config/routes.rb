Rails.application.routes.draw do
  devise_for :users
  resources :rooms do
    get 'recorded_session', to: 'rooms#recorded_session'
    get 'start_session', to: 'rooms#start_session'
    get 'join_session', to: 'rooms#join_session'
    get 'start_archive', to: 'rooms#start_archive'
    get 'stop_archive', to: 'rooms#stop_archive'
    get 'delete_archive', to: 'rooms#delete_archive'
  end
  root 'rooms#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
