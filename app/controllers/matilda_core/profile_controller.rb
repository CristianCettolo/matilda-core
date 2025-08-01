# frozen_string_literal: true

module MatildaCore

  # ProfileController.
  class ProfileController < MatildaCore::ApplicationController

    before_action :session_present_check

    def manage_main_view
      section_head_set(@session&.user&.complete_name, matilda_core.root_path)
    end

    def manage_password_view
      section_head_set(@session&.user&.complete_name, matilda_core.root_path)
    end

    def manage_email_view
      section_head_set(@session&.user&.complete_name, matilda_core.root_path)
    end

    def edit_info_action
      command = command_manager(generate_edit_info_command)
      return unless command

      render_json_success({})
    end

    def edit_username_action
      command = command_manager(generate_edit_username_command)
      return unless command

      render_json_success({})
    end

    def edit_useless_sessions_action
      # Recupero il parametro dal form
      hide_useless_sessions = params[:hide_useless_sessions] == '1'
      
      # Verifico che l'utente esista
      user = MatildaCore::User.find_by(uuid: @session.user_uuid)
      unless user
        render_json_error('User not found')
        return
      end
      
      # Aggiorno il campo hide_useless_sessions dell'utente
      result = user.update(hide_useless_sessions: hide_useless_sessions)
      
      unless result
        render_json_error(user.errors.full_messages.join(', '))
        return
      end
      
      # Registro l'operazione nei log (opzionale)
      log_info = { 
        hide_useless_sessions: hide_useless_sessions,
        uuid: user.uuid, 
        username: user.username 
      }
      
      # Ritorno un successo
      render_json_success({})
    end

    def create_email_action
      command = command_manager(generate_create_email_command)
      return unless command

      render_json_success({})
    end

    def remove_email_action
      command = command_manager(generate_remove_email_command)
      return unless command

      render_json_success({})
    end

    def toggle_email_primary_action
      command = command_manager(generate_toggle_email_primary_command)
      return unless command

      render_json_success({})
    end

    def edit_password_action
      command = command_manager(generate_edit_password_command)
      return unless command

      render_json_success({})
    end
    
    def edit_units_system_action
      # Recupero il parametro dal form
      units_system = params[:units_system]
      
      # Verifico che l'utente esista
      user = MatildaCore::User.find_by(uuid: @session.user_uuid)
      unless user
        render_json_error('User not found')
        return
      end
      
      # Verifico che il sistema di unità sia valido
      unless MatildaCore::User::UNITS_SYSTEMS.include?(units_system)
        render_json_error('Invalid units system')
        return
      end
      
      # Aggiorno il sistema di unità dell'utente
      result = user.update(units_system: units_system)
      
      unless result
        render_json_error(user.errors.full_messages.join(', '))
        return
      end
      
      # Registro l'operazione nei log
      log_info = { 
        units_system: units_system,
        uuid: user.uuid, 
        username: user.username 
      }
      
      # Ritorno un successo
      render_json_success({})
    end

    private

    def generate_edit_info_command
      command_params = params.permit(:name, :surname, :mask_sensitive_data, :username, :units_system, :hide_useless_sessions)
      command_params[:user_uuid] = @session.user_uuid
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Profile::EditInfoCommand.new(command_params)
    end

    def generate_edit_username_command
      command_params = params.permit(:username)
      command_params[:user_uuid] = @session.user_uuid
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Profile::EditUsernameCommand.new(command_params)
    end

    def generate_create_email_command
      command_params = params.permit(:email)
      command_params[:user_uuid] = @session.user_uuid
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Profile::CreateEmailCommand.new(command_params)
    end

    def generate_remove_email_command
      command_params = params.permit(:email)
      command_params[:user_uuid] = @session.user_uuid
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Profile::RemoveEmailCommand.new(command_params)
    end

    def generate_toggle_email_primary_command
      command_params = params.permit(:email)
      command_params[:user_uuid] = @session.user_uuid
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Profile::ToggleEmailPrimaryCommand.new(command_params)
    end

    def generate_edit_password_command
      command_params = params.permit(:password_old, :password, :password_confirmation)
      command_params[:user_uuid] = @session.user_uuid
      command_params[:log_who] = @session.user_uuid
      MatildaCore::Profile::EditPasswordCommand.new(command_params)
    end

  end

end