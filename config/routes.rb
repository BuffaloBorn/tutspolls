Rails.application.routes.draw do

  root 'polls#index'
  resources :polls do
      resources :questions
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
