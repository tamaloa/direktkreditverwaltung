Direktkreditverwaltung::Application.routes.draw do


  resources :emails


  resources :mail_templates


  resources :companies


  resources :contract_terminators


  resources :contract_versions


  get "home/index"
  get "contracts/interest"
  get "contracts/interest_transfer_list"
  get "contracts/interest_average"
  get "contracts/expiring"
  get "contracts/remaining_term"
  get "contracts/sum_per_interest"

  resources :accounting_entries
  
  resources :contracts do
    resources :accounting_entries
    resources :contract_versions
  end

  resources :contacts do
    resources :contracts do
      resources :accounting_entries
    end  
  end

  resources :year_end_closings do
    member do
      get :send_emails
      get :send_test_email
    end
  end
  resources :year_closing_statements, only: [:show]


  root :to => "home#index"
  
end
