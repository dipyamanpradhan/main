Rails.application.routes.draw do
  namespace :api do
    resources :employees do
      member do
        get 'tax_deduction'
      end
    end
  end
end
