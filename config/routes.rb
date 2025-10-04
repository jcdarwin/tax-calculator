Rails.application.routes.draw do
  root "homepage#index"

  namespace :api do
    namespace :v1 do
      resource :tax_calculation, only: [ :show ], controller: "tax_calculation"
    end
  end
end
