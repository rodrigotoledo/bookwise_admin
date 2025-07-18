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
end
