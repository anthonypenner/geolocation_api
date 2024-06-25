# config/routes.rb

Rails.application.routes.draw do
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :geolocations, only: [:create, :show, :destroy], param: :ip_or_url, constraints: { ip_or_url: /[^\/]+/ }
    end
  end
end
