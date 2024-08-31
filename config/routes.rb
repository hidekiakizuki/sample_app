# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :articles

  # Defines the root path route ("/")
  # root "articles#index"
  root 'articles#index'

  get '/healthy'   => 'monitoring#healthy'
  get '/synthetic' => 'monitoring#synthetic'
  get '/crash' => 'crash#index'

  post '/csp-violation-report-endpoint', to: 'csp_violation_report#receive'
end