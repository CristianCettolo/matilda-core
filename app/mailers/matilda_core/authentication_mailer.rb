# frozen_string_literal: true

module MatildaCore

  # AuthenticationMailer.
  class AuthenticationMailer < MatildaCore::ApplicationMailer

    default template_path: 'matilda_core/mailers/authentication'

    def invite(user_uuid, email)
      @user = MatildaCore::User.find_by(uuid: user_uuid)
      return unless @user

      mail(to: email, subject: "Welcome to #{MatildaCore.config.global_title}")
    end

    def verify_email(user_uuid, email)
      @user = MatildaCore::User.find_by(uuid: user_uuid)
      return unless @user

      mail(to: email, subject: "Verify your email - #{MatildaCore.config.global_title}")
    end

    def recover_password(user_uuid)
      @user = MatildaCore::User.find_by(uuid: user_uuid)
      return unless @user

      mail(to: @user.email, subject: "Recover password - #{MatildaCore.config.global_title}")
    end

  end

end
