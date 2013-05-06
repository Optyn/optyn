require 'openssl'
require 'base64'

module Surveys
  class Encryptor
    def self.encrypt(user_email, survey_id)
      plain_text = "#{user_email}--#{survey_id}"
      cipher = configure
      ciphertext = cipher.update(plain_text)
      ciphertext.<<(cipher.final)
      encoded_cipher_text = Base64.strict_encode64(ciphertext)
      CGI.escape(encoded_cipher_text)
    end

    def self.decrypt(authtoken)
      decrypt_cipher_text = Base64.decode64(authtoken)
      cipher = configure
      cipher.decrypt
      plaintext = cipher.update(decrypt_cipher_text)
      plaintext.<<(cipher.final)
      plaintext
    end

    def self.configure
      # Encrypt plaintext using Triple DES
      cipher = OpenSSL::Cipher::Cipher.new("des-ede3-cbc")
      cipher.encrypt # Call this before setting key or iv
      cipher.key = 'SurveyEncryptorSurveyEncryptor'
      cipher.iv = '9p5yn123'
      cipher
    end
  end
end