# frozen_string_literal: true

module MatildaCore

  module Users

    # EditInfoEvent.
    class EditInfoEvent < MatildaCore::ApplicationEvent

      name_is :matilda_core_users_edit_info

      payload_attributes_are :user_uuid, :name, :surname, :mask_sensitive_data, :log_who

      to_write_event do
        set_not_saved unless save_event && MatildaCore::User.find_by(
          uuid: payload[:user_uuid]
        )&.update(
          name: payload[:name],
          surname: payload[:surname],
          mask_sensitive_data: payload[:mask_sensitive_data]
        )
      end

    end

  end

end