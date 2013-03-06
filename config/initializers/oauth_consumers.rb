# edit this file to contain credentials for the OAuth services you support.
# each entry needs a corresponding token model.

OAUTH_CREDENTIALS={
  :my_experiment=>{
    :key => 'ON2MMg1MMPSCWSjkJsGiZg', 
    :secret => 'RTxDzGKaQf0xcA9X2vZ07aJZOS51y8yh3d93fb7jkso',
#    :key => 'wFmOHFsJGwS49iI55Lcw', 
#    :secret => 'WM2D9ohT9gizlQUWFMdUgabvjtll0uAN9Sewn4G1UQ',
    :options => {  :site => "http://www.myexperiment.org", 
      :request_token_path => "/oauth/request_token", 
      :access_token_path => "/oauth/access_token", 
      :authorize_path=> "/oauth/authorize"}
  }
} unless defined? OAUTH_CREDENTIALS

load 'oauth/models/consumers/service_loader.rb'
