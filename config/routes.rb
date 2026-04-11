Rails.application.routes.draw do
  get "orders/index"
  get "orders/show"
  root "products#index"

  resources :products do
  post "add_to_cart", on: :member
  end

  get "cart", to: "products#cart"
  post "remove_from_cart/:id", to: "products#remove_from_cart", as: :remove_from_cart
  post "increase_quantity/:id", to: "products#increase_quantity", as: :increase_quantity
  post "decrease_quantity/:id", to: "products#decrease_quantity", as: :decrease_quantity
  post "checkout", to: "products#checkout"

  post "checkout", to: "products#checkout"

  get "up" => "rails/health#show", as: :rails_health_check

  resources :orders, only: [ :index, :show ]
end
