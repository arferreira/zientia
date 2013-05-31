Zientia::Application.routes.draw do

  get "current/index"

  get "dashboard/index"

  get "usuario/logar"

  match 'current' => 'current#index'

  devise_for :users

  get "intro/index"

  devise_scope :user do
  
  get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  
  end

 
  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'intro#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
