TliteR3::Application.routes.draw do

  match '/about_portal' => 'about_portal#index'
  match '/cookies' => 'about_portal#cookies'
  match '/about' => 'about_portal#index'

  resources :workflow_ports do
    member do
      post "download"
    end
  end
 
  resources :results

  resources :password_resets

  resources :oauth_consumers do
    member do
      get :callback
      get :callback2
      match 'client/*endpoint' => 'oauth_consumers#client'
    end
  end

  resources :announcements

  resources :credentials

  #*****************************************************
  # mapping for the authentication redirections 
  get "log_in" => "sessions#new", :as => "log_in"
  get "log_out" => "sessions#destroy", :as => "log_out" 
  get "sign_up" => "users#new", :as => "sign_up" 
  
  resources :users  
  resources :sessions 
  #*****************************************************

  resources :runs

  #*****************************************************
  # mapping for refreshing runs list
  get 'runs_refresh_list'  => 'runs#refresh_list'
  # mapping for refreshing results if run has not finished
  match 'runs/refresh/:id'  => 'runs#refresh'
  match 'runs/interaction/:id/:interactionid' => 'runs#interaction'
  #*****************************************************



  resources :workflows do
    member do
      put "make_public"
      put "make_private"
      post "save_custom_inputs"
      post "save_custom_outputs"
    end
  end
  #*****************************************************
  # mapping for the redirection when checking results
  match 'runs/', :controller => 'runs', :action => 'update_all'
  #*****************************************************

  #*****************************************************
  # mapping for the redirection when creating a new run
  match 'workflows/:id/newrun/', :controller => 'runs', :action => 'new_run'
  #*****************************************************

  #*****************************************************
  # mapping for the redirection when downloading a workflow
  match 'workflows/:id/download/', :controller => 'workflows', :action => 'download'
  #*****************************************************  

  #*****************************************************
  # mapping for the redirection when downloading a result
  match 'results/:id/download/', :controller => 'results', :action => 'download'
  #*****************************************************


  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

end
