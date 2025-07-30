# frozen_string_literal: true

module MatildaCore

  module Users

    # EditInfoEvent.
    class EditInfoEvent < MatildaCore::ApplicationEvent

      name_is :matilda_core_users_edit_info

      payload_attributes_are :user_uuid, :name, :surname, :mask_sensitive_data, :log_who, :username, :units_system, :hide_useless_sessions

      to_write_event do
        set_not_saved unless save_event && MatildaCore::User.find_by(
          uuid: payload[:user_uuid]
        )&.update(
          name: payload[:name],
          surname: payload[:surname],
          mask_sensitive_data: payload[:mask_sensitive_data],
          username: payload[:username],
          units_system: payload[:units_system],
          hide_useless_sessions: payload[:hide_useless_sessions]
        )
      end

    end

  end

end