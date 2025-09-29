# frozen_string_literal: true

module MatildaCore

  module Authentication

    # SignupCommand.
    # Permette ad un utente di registrarsi all'interno della piattaforma.
    # TODO: Gestire salvataggio privacy.
    class SignupCommand < MatildaCore::ApplicationCommand

      attr_reader :session_uuid, :user_uuid

      validates :username,
                presence: true, type: :string, blank: false,
                regex: MatildaCore::User::USERNAME_REGEX,
                err: I18n.t('matilda_core.messages.username_not_valid')

      validates :email,
                presence: true, type: :string, blank: false,
                regex: MatildaCore::User::EMAIL_REGEX,
                err: I18n.t('matilda_core.messages.email_not_valid')

      validates :name,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.name_not_valid')

      validates :surname,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.surname_not_valid')

      validates :password,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.password_not_valid')

      validates :password_confirmation,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.password_not_valid')

      validates :privacy, type: :string

      validates :ip_address, type: :string

      validates :log_who, type: :string

      to_normalize_params do
        params[:email] = params[:email].downcase
      end

      to_validate_params do
        # verifico che le due password siano uguali
        if params[:password] != params[:password_confirmation]
          err(I18n.t('matilda_core.messages.password_not_match'), code: :password_confirmation)
          break
        end

        # verifico che la password non sia uguale al nome o al cognome
        if params[:password] == params[:name] || params[:password] == params[:surname]
          err(I18n.t('matilda_core.messages.password_cannot_match_name'), code: :password)
          break
        end

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
        
        # Se ho trovato una parola vietata, mostro l'errore con la parola vietata
        if found_forbidden_name
          err(I18n.t('matilda_core.messages.forbidden_word_in_name', word: found_forbidden_name), code: :invalid_name_or_surname)
          break
        end

        # Verifico che la password rispetti il regex
        unless params[:password].match?(MatildaCore::User::PASSWORD_REGEX)
          err(I18n.t('matilda_core.messages.password_regex'), code: :invalid_password)
          break
        end

        # Verifico che la password sia lunga almeno 8 caratteri
        if params[:password].length < 8
          err(I18n.t('matilda_core.messages.password_length'), code: :invalid_password_length)
          break
        end
      end

      to_validate_logic do
        unless MatildaCore.config.authentication_permit_signup
          err(I18n.t('matilda_core.messages.signup_not_permitted'))
          break
        end

        # verifico che l'username sia univoco
        if MatildaCore::User.find_by(username: params[:username])
          err(I18n.t('matilda_core.messages.username_already_taken'), code: :username)
          break
        end

        # verifico che la email sia univoca
        if MatildaCore::UserEmail.find_by(email: params[:email])
          err(I18n.t('matilda_core.messages.email_already_taken'), code: :email)
          break
        end
      end

      to_initialize_events do
        @session_uuid = SecureRandom.uuid
        @user_uuid = SecureRandom.uuid

        # creo il nuovo utente
        event_user = MatildaCore::Users::CreateEvent.new(
          user_uuid: @user_uuid,
          username: params[:username],
          name: params[:name],
          surname: params[:surname],
          password: BCrypt::Password.create(params[:password]),
          log_who: params[:log_who]
        )
        internal_error && break unless event_user.saved?

        # memorizzo l'indirizzo email del nuovo utente
        event_email = MatildaCore::Users::CreateEmailEvent.new(
          user_uuid: @user_uuid,
          email: params[:email],
          primary: true,
          log_who: params[:log_who]
        )

        internal_error && break unless event_email.saved?

        # Email di verifica
        AuthenticationMailer.verify_email(@user_uuid, params[:email]).deliver_now

        # creo una nuova sessione
        # event_session = MatildaCore::Users::CreateSessionEvent.new(
        #   session_uuid: @session_uuid,
        #   user_uuid: @user_uuid,
        #   ip_address: params[:ip_address],
        #   log_who: params[:log_who]
        # )
        # internal_error && break unless event_session.saved?

        # aggiungo l'utente al gruppo di default se e' stato specificato nella configurazione generica
        if MatildaCore.config.authentication_signup_default_group_uuid && MatildaCore::Group.find_by(uuid: MatildaCore.config.authentication_signup_default_group_uuid)
          event_membership = MatildaCore::Memberships::CreateEvent.new(
            user_uuid: @user_uuid,
            group_uuid: MatildaCore.config.authentication_signup_default_group_uuid,
            log_who: params[:log_who]
          )
          internal_error && break unless event_membership.saved?

          # aggiorno i permessi di default dell'utente
          if MatildaCore.config.authentication_signup_default_group_permissions&.length&.positive?
            event_permissions = MatildaCore::Memberships::EditPermissionsEvent.new(
              user_uuid: @user_uuid,
              group_uuid: MatildaCore.config.authentication_signup_default_group_uuid,
              permissions: MatildaCore.config.authentication_signup_default_group_permissions,
              log_who: params[:log_who]
            )
            internal_error && break unless event_permissions.saved?
          end
        end

      end

    end

  end

end