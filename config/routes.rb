# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  resources :articles

  # Defines the root path route ("/")
  # root "articles#index"
  root 'articles#index'

  get '/async_test_job' => 'async_test_job#enqueue'

  get '/healthy'   => 'monitoring#healthy'
  get '/synthetic' => 'monitoring#synthetic'

  post '/csp-violation-report-endpoint', to: 'csp_violation_report#receive'

  # test
  get '/kill' => 'kill#index'

  get 'log/debug'   => 'log#debug'
  get 'log/info'    => 'log#info'
  get 'log/warn'    => 'log#warn'
  get 'log/error'   => 'log#error'
  get 'log/fatal'   => 'log#fatal'
  get 'log/unknown' => 'log#unknown'
end
