Rails.application.routes.draw do
  resources :assignments
  resources :projects
  resources :surveys
  resources :conferences
  resources :songs
  resources :users
end
