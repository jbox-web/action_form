# frozen_string_literal: true

Rails.application.routes.draw do
  root 'welcome#index'
  resources :assignments
  resources :projects
  resources :surveys
  resources :conferences
  resources :songs
  resources :users
end
