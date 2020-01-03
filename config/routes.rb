# frozen_string_literal: true

MatildaCore::Engine.routes.draw do
  root 'application#index'

  # authentication
  get 'authentication/login-view', to: 'authentication#login_view', as: 'authentication_login_view'
  get 'authentication/signup-view', to: 'authentication#signup_view', as: 'authentication_signup_view'
  get 'authentication/recover-password-view', to: 'authentication#recover_password_view', as: 'authentication_recover_password_view'
  get 'authentication/recover-password-complete-view', to: 'authentication#recover_password_complete_view', as: 'authentication_recover_password_complete_view'
  get 'authentication/update-password-view', to: 'authentication#update_password_view', as: 'authentication_update_password_view'
  get 'authentication/update-password-complete-view', to: 'authentication#update_password_complete_view', as: 'authentication_update_password_complete_view'
  post 'authentication/login-action', to: 'authentication#login_action', as: 'authentication_login_action'
  post 'authentication/signup-action', to: 'authentication#signup_action', as: 'authentication_signup_action'
  post 'authentication/recover-password-action', to: 'authentication#recover_password_action', as: 'authentication_recover_password_action'
  post 'authentication/update-password-action', to: 'authentication#update_password_action', as: 'authentication_update_password_action'
  post 'authentication/logout-action', to: 'authentication#logout_action', as: 'authentication_logout_action'

  # groups
  get 'groups/index-view', to: 'groups#index_view', as: 'groups_index_view'
  get 'groups/dash-view', to: 'groups#dash_view', as: 'groups_dash_view'
  post 'groups/select-action', to: 'groups#select_action', as: 'groups_select_action'
  post 'groups/create-action', to: 'groups#create_action', as: 'groups_create_action'

  # profile
  get 'profile/index-view', to: 'profile#index_view', as: 'profile_index_view'
  post 'profile/edit-info-action', to: 'profile#edit_info_action', as: 'profile_edit_info_action'
  post 'profile/edit-username-action', to: 'profile#edit_username_action', as: 'profile_edit_username_action'
  post 'profile/create-email-action', to: 'profile#create_email_action', as: 'profile_create_email_action'
  post 'profile/remove-email-action', to: 'profile#remove_email_action', as: 'profile_remove_email_action'
  post 'profile/toggle-email-primary-action', to: 'profile#toggle_email_primary_action', as: 'profile_toggle_email_primary_action'
  post 'profile/edit-password-action', to: 'profile#edit_password_action', as: 'profile_edit_password_action'

  # memberships
  get 'app-memberships/index-view', to: 'app_memberships#index_view', as: 'app_memberships_index_view'
  get 'app-memberships/invitation-view', to: 'app_memberships#invitation_view', as: 'app_memberships_invitation_view'
  get 'app-memberships/edit-view', to: 'app_memberships#edit_view', as: 'app_memberships_edit_view'
  post 'app-memberships/invitation-action', to: 'app_memberships#invitation_action', as: 'app_memberships_invitation_action'
  post 'app-memberships/edit-permissions-action', to: 'app_memberships#edit_permissions_action', as: 'app_memberships_edit_permissions_action'
end
