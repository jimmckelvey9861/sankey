Rails.application.routes.draw do
  get "sankey", to: "sankey#index"
  root "sankey#index"
end