Rails.application.routes.draw do
  get 'tokens/generate'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get '/generate_token', to: 'tokens#generate'
  get '/validate_token', to: 'tokens#validate'
  delete '/delete_token', to: 'tokens#delete'
  put '/renew_token', to: 'tokens#renew'
end
