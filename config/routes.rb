# frozen_string_literal: true

Rails.application.routes.draw do
  root "dashboard#index"
  resources :books do
    member do
      patch :return_book, as: :return
      patch :borrow
    end
  end
  resource :session
  resource :registration, only: %i[new create]

  namespace :api do
    namespace :v1 do
      post "sign_up", to: "registrations#create", as: :sign_up
      post "sign_in", to: "sessions#create", as: :sign_in
      delete "logout", to: "sessions#destroy", as: :logout
      get "for_member", to: "dashboard#for_member", as: :dashboard_for_member
      get "for_librarian", to: "dashboard#for_librarian", as: :dashboard_for_librarian
      resources :books do
        member do
          patch :return_book, as: :return
          patch :borrow
        end
      end
    end
  end
end
