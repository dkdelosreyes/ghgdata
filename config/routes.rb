Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  get :facilities_geo, to: 'facilities#geo', constraints: { format: :json }, defaults: { format: :json }
end
