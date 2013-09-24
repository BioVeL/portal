Portal::Application.routes.draw do

  devise_for :users

  resources :workflow_errors

  match '/about_portal' => 'about_portal#index'
  match '/cookies' => 'about_portal#cookies'
  match '/about' => 'about_portal#index'

  resources :workflow_ports do
    member do
      post "download"
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

  resources :users, :except => [:create, :destroy, :show]

  mount TavernaPlayer::Engine, :at => "/"

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
  # mapping for the redirection when downloading a workflow
  match 'workflows/:id/download/', :controller => 'workflows', :action => 'download'
  #*****************************************************

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'welcome#index'

end
