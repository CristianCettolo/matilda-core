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

      validates :username, type: :string
      
      validates :phone, type: :string
      
      validates :units_system, type: :string   
                
      validates :log_who, type: :string

      to_validate_logic do
        # verifico che l'utente esista
        unless MatildaCore::User.find_by(uuid: params[:user_uuid])
          err(I18n.t('matilda_core.messages.user_not_valid'), code: :user_uuid)
          break
        end
      end

      to_validate_params do
         # Verifico se il nome o il cognome contengono parole vietate
          forbidden_names = Setting.first&.forbidden_names || []
          found_forbidden_name = nil
          
          # Controllo nel nome
          forbidden_names.each do |forbidden|
            if params[:name].downcase.include?(forbidden.downcase)
              found_forbidden_name = forbidden
              break
            end
          end
          
          # Se non ho trovato nel nome, controllo nel cognome
          if found_forbidden_name.nil?
            forbidden_names.each do |forbidden|
              if params[:surname].downcase.include?(forbidden.downcase)
                found_forbidden_name = forbidden
                break
              end
            end
          end

          # Se non ho trovato nel cognome, controllo nello username
          if found_forbidden_name.nil?
            forbidden_names.each do |forbidden|
              if params[:username].downcase.include?(forbidden.downcase)
                found_forbidden_name = forbidden
                break
              end
            end
          end
          
          # Se ho trovato una parola vietata, mostro l'errore con la parola vietata
          if found_forbidden_name
            err(I18n.t('matilda_core.messages.forbidden_word_in_name', word: found_forbidden_name), code: :invalid_name_or_surname)
            break
          end
      end

      to_initialize_events do
        # Gestisci i valori nil per i checkbox (quando non selezionati arrivano nil)
        mask_value = params[:mask_sensitive_data] == '1' || params[:mask_sensitive_data] == true
        hide_value = params[:hide_useless_sessions] == '1' || params[:hide_useless_sessions] == true
        
        event = MatildaCore::Users::EditInfoEvent.new(
          user_uuid: params[:user_uuid],
          name: params[:name],
          surname: params[:surname],
          mask_sensitive_data: mask_value,
          log_who: params[:log_who],
          units_system: params[:units_system],
          phone: params[:phone],
          hide_useless_sessions: hide_value,
          username: params[:username]
        )
        internal_error && break unless event.saved?
      end

    end

  end

end