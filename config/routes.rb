# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :articles

  # Defines the root path route ("/")
  # root "articles#index"
  root 'articles#index'

  get '/healthy'   => 'monitoring#healthy'
  get '/synthetic' => 'monitoring#synthetic'

  post '/csp-violation-report', to: 'csp_violation_report#receive'
end
