# frozen_string_literal: true

module MatildaCore

  module Profile

    # EditPasswordCommand.
    class EditPasswordCommand < MatildaCore::ApplicationCommand

      validates :user_uuid,
                presence: true, type: :string, blank: false,
                err: 'Utente non valido'

      validates :password_old,
                presence: true, type: :string, blank: false,
                err: 'Password attuale non valida'

      validates :password,
                presence: true, type: :string, blank: false,
                err: 'Password non valida' # TODO: Aggiungere Regex password.

      validates :password_confirmation,
                presence: true, type: :string, blank: false,
                err: 'Password non valida' # TODO: Aggiungere Regex password.

      validates :log_who, type: :string

      to_validate_params do
        # verifico che le due password coincidano
        unless params[:password] == params[:password_confirmation]
          err('Le due password non coincidono', code: :password_confirmation)
          break
        end

        # Verifico che la password rispetti il regex
        unless params[:password].match?(MatildaCore::User::PASSWORD_REGEX)
          err('La password deve contenere almeno: 1 lettera maiuscola, 1 numero ed 1 simbolo', code: :invalid_password)
          break
        end

        # Verifico che la password sia lunga almeno 8 caratteri
        if params[:password].length < 8
          err('La password deve essere lunga almeno 8 caratteri', code: :invalid_password_length)
          break
        end
      end

      to_validate_logic do
        user = MatildaCore::User.find_by(uuid: params[:user_uuid])

        # verifico che l'utente esista
        unless user
          err('Utente non valido', code: :user_uuid)
          break
        end

        # verifico che la vecchia password sia corretta
        unless BCrypt::Password.new(user.password) == params[:password_old]
          err('Password attuale non corretti', code: :password_old)
          break
        end
      end

      to_initialize_events do
        # imposto la nuova password all'utente
        event_password = MatildaCore::Users::EditPasswordEvent.new(
          user_uuid: params[:user_uuid],
          password: BCrypt::Password.create(params[:password]),
          log_who: params[:log_who]
        )
        internal_error && break unless event_password.saved?
      end

    end

  end

end
