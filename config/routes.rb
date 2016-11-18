Rails.application.routes.draw do

  get 'event_response/create'

  get 'event_response/destroy'

  post 'event_response/create'

  post 'event_response/destroy'

  resources :events do |variable|
    get 'event_responses', on: :member, defaults: {format: :json}
  end
  resources :event_locations
  resources :event_categories
  resources :club_slides
  resources :academic_periods
  resources :role_types
  resources :roles_users
  devise_for :users,:controllers => {:sessions=>"sessions"}
  resources :roles
  resources :club_contacts
  resources :club_settings
  resources :club_board_of_directors
  resources :club_board_of_supervisories
  resources :assistant_consultants
  resources :club_periods do |variable|
    get 'member_list', on: :member, defaults: {format: :json}
  end
  resources :announcements
  resources :system_announcements
  resources :clubs
  resources :club_categories
  get 'unsubscribe_request' => 'roles#unsubscribe_request'
  get 'club_users' => 'roles#club_users'
  get 'find_ogrenci' =>'users#find_ogrenci'
  get 'find_personel' =>'users#find_personel'
  root 'clubs#index'
end
