# frozen_string_literal: true

module MatildaCore

  module Users

    # EditInfoEvent.
    class EditInfoEvent < MatildaCore::ApplicationEvent

      name_is :matilda_core_users_edit_info

      payload_attributes_are :user_uuid, :name, :surname, :mask_sensitive_data, :log_who, :username, :units_system, :hide_useless_sessions, :phone, :email

      to_write_event do
        user_email = MatildaCore::User.find_by(uuid: payload[:user_uuid])&.user_emails.find_by(primary: true) || MatildaCore::User.find_by(uuid: payload[:user_uuid])&.user_emails&.first

        user_email.update(email: payload[:email]) if user_email && payload[:email].present? && user_email.email != payload[:email]

        set_not_saved unless save_event && MatildaCore::User.find_by(
          uuid: payload[:user_uuid]
        )&.update(
          name: payload[:name],
          surname: payload[:surname],
          mask_sensitive_data: payload[:mask_sensitive_data],
          username: payload[:username],
          phone: payload[:phone],
          units_system: payload[:units_system],
          hide_useless_sessions: payload[:hide_useless_sessions]
        )
      end

    end

  end

end