# frozen_string_literal: true

module MatildaCore

  module Profile

    # EditInfoCommand.
    class EditInfoCommand < MatildaCore::ApplicationCommand

      validates :user_uuid,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.user_not_valid')

      validates :name,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.name_not_valid')

      validates :surname,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.surname_not_valid')

      validates :mask_sensitive_data, type: :boolean
                
      validates :log_who, type: :string

      to_validate_logic do
        # verifico che l'utente esista
        unless MatildaCore::User.find_by(uuid: params[:user_uuid])
          err(I18n.t('matilda_core.messages.user_not_valid'), code: :user_uuid)
          break
        end
      end

      to_initialize_events do
        event = MatildaCore::Users::EditInfoEvent.new(
          user_uuid: params[:user_uuid],
          name: params[:name],
          surname: params[:surname],
          mask_sensitive_data: params[:mask_sensitive_data],
          log_who: params[:log_who]
        )
        internal_error && break unless event.saved?
      end

    end

  end

end