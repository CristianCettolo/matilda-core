# frozen_string_literal: true

module MatildaCore

  module Authentication

    # LoginCommand.
    class LoginCommand < MatildaCore::ApplicationCommand

      attr_reader :session_uuid, :user_uuid

      validates :username_email,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.username_email_not_valid')

      validates :password,
                presence: true, type: :string, blank: false,
                err: I18n.t('matilda_core.messages.password_not_valid')

      validates :ip_address, type: :string

      validates :log_who, type: :string

      to_normalize_params do
        params[:username_email] = params[:username_email].downcase
      end

      to_validate_logic do
        user = MatildaCore::User.find_by(username: params[:username_email])
        user ||= MatildaCore::User.joins(:user_emails).find_by(matilda_core_user_emails: { email: params[:username_email] })

        unless user
          err(I18n.t('matilda_core.messages.username_email_not_valid'), code: :username_email)
          break
        end

        if user.password.blank?
          err('Profilo non ancora attivo. Esegui la procedura di aggiornamento password per poter accedere', code: :username_email)
          break
        end

        unless BCrypt::Password.new(user.password) == params[:password]
          err(I18n.t('matilda_core.messages.password_not_valid'), code: :password)
          break
        end

        unless user.email_verified?
          err(I18n.t('matilda_core.messages.email_not_verified'), code: :email)
          break
        end

        @user_uuid = user.uuid
      end

      to_initialize_events do
        @session_uuid = SecureRandom.uuid

        # creo una nuova sessione
        event_session = MatildaCore::Users::CreateSessionEvent.new(
          session_uuid: @session_uuid,
          user_uuid: @user_uuid,
          ip_address: params[:ip_address],
          log_who: params[:log_who]
        )
        internal_error && break unless event_session.saved?
      end

    end

  end

end
