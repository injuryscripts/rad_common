RadCommon::Engine.routes.draw do
  get 'global_search', to: 'search#global_search'
  get 'global_search_result', to: 'search#global_search_result'

  post :email_error, to: 'rad_common/sendgrid#email_error'

  resources :companies, only: [] do
    post :global_validity_check, on: :member
  end

  resources :system_messages, only: %i[new create show]

  resources :system_usages, only: %i[index]
  resources :notification_types, only: %i[index edit update]
  resources :notification_settings, only: %i[index create]

  resources :attachments, only: :destroy
end
