# frozen_string_literal: true

module MatildaCore

  module Users

    # EditInfoEvent.
    class EditInfoEvent < MatildaCore::ApplicationEvent

      name_is :matilda_core_users_edit_info

      payload_attributes_are :user_uuid, :name, :surname, :mask_sensitive_data, :log_who, :username, :units_system, :hide_useless_sessions, :phone, :email

      to_write_event do
        user = MatildaCore::User.find_by(uuid: payload[:user_uuid])
        user_email = user&.user_emails.find_by(primary: true) || user&.user_emails&.first

        begin
          if user_email
            user_email.update!(email: payload[:email])
          else
            user.user_emails.create!(email: payload[:email], primary: true)
          end
        rescue ActiveRecord::RecordNotUnique
          set_not_saved
        end

        set_not_saved unless save_event && user&.update(
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