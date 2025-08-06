# frozen_string_literal: true

module MatildaCore

  # GroupsController.
  class GroupsController < MatildaCore::ApplicationController

    before_action :session_present_check, :check_if_verified

    def index_view
      if MatildaCore.config.groups_root_path
        redirect_to MatildaCore.config.groups_root_path
        return
      end

      @group = @session.group

      unless @group
        redirect_to matilda_core.groups_select_view_path
        return
      end

      section_head_set('Dashboard')
      sidebar_set('matilda_core.groups')
    end

    def select_view
      @group = @session.group

      if @group
        redirect_to matilda_core.groups_index_view_path
        return
      end

      @groups = @session.user.groups.order('name ASC')
      sidebar_set('matilda_core.groups')
    end

    def select_action
      @group = @session.user.groups.find_by(uuid: params[:group_uuid])

      unless @group
        render_json_fail
        return
      end

      render_json_success(token: session_update_group(@group.uuid))
    end

    def unselect_action
      render_json_success(token: session_update_group(nil))
    end

    def create_action
      command = command_manager(generate_create_command)
      return unless command

      render_json_success({})
    end

    private

    def generate_create_command
      command_params = params.permit(:name)
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Groups::CreateGroupCommand.new(command_params)
    end

    def check_if_verified
      return unless session_present?

      if @session.user&.email_verified?
        return true
      else
        flash.alert = I18n.t('application.messages.email_not_verified')
        session_destroy
      end
    end

  # FUNZIONI DI CONTROLLO PRIVACY POLICY
    ##############################################################################################################

    def check_privacy_policy_acceptance
      return unless session_present?
      
      current_policy_version = Setting.first&.privacy_policy_version
      return unless current_policy_version 
      
      user = MatildaCore::User.find_by(uuid: @session.user_uuid)
      return unless user 
      
      latest_consent = user.privacy_consents.find_by(privacy_version: current_policy_version)
      
      unless latest_consent&.authorizations&.include?('privacy')
        logout_current_user
        flash[:alert] = I18n.t('application.messages.privacy_policy_updated')
        redirect_to matilda_core.authentication_login_view_path
      end
    end

    def logout_current_user
      return unless session_present?
      
      logout_command = MatildaCore::Authentication::LogoutCommand.new(
        session_uuid: @session.user_session_uuid,
        log_who: 'system_privacy_policy_check'
      )
      
      # Execute logout command
      logout_command.completed?
      
      # Destroy session
      session_destroy
    end

  end

end
