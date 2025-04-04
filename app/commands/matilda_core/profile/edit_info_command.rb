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
                
      validates :log_who, type: :string

      to_validate_logic do
        # verifico che l'utente esista
        unless MatildaCore::User.find_by(uuid: params[:user_uuid])
          err(I18n.t('matilda_core.messages.user_not_valid'), code: :user_uuid)
          break
        end
      end

      to_initialize_events do
        # Converto il valore di mask_sensitive_data in un booleano prima di passarlo all'evento
        mask_value = params[:mask_sensitive_data] == '1' || params[:mask_sensitive_data] == true
        
        event = MatildaCore::Users::EditInfoEvent.new(
          user_uuid: params[:user_uuid],
          name: params[:name],
          surname: params[:surname],
          mask_sensitive_data: mask_value,
          log_who: params[:log_who]
        )
        internal_error && break unless event.saved?
      end

    end

  end

end