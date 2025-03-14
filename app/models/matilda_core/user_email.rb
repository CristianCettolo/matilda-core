# frozen_string_literal: true

module MatildaCore

  # UserEmail.
  class UserEmail < ApplicationRecord

    belongs_to :user, foreign_key: :user_uuid, optional: true

    # Override dell'attributo email per mascherarlo quando necessario
    def email
      value = self[:email]
      return value unless user&.mask_sensitive_data?
      
      # Maschera l'email ma mantiene visibile il dominio
      parts = value.split('@')
      return value if parts.length != 2
      
      username = mask_string(parts[0])
      "#{username}@#{parts[1]}"
    end

    private

    # Metodo per mascherare una stringa mantenendo visibili primo e ultimo carattere
    def mask_string(str)
      return str if str.nil? || str.length <= 2
      
      first = str[0]
      last = str[-1]
      middle = '*' * (str.length - 2)
      "#{first}#{middle}#{last}"
    end

  end

end