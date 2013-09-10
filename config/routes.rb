Portal::Application.routes.draw do
  mount TavernaLite::Engine => "/taverna_lite"

  devise_for :users

  resources :interaction_entries
  match '/about_portal' => 'about_portal#index'
  match '/cookies' => 'about_portal#cookies'
  match '/about' => 'about_portal#index'

  resources :workflow_ports do
    member do
      post "download"
    end
  end

  resources :results do
    member do
      get "download"
      get "inlinepdf"
    end
  end

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

  resources :users, :except => [:create, :destroy, :show]

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
      post "save_custom_errors"
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

end
