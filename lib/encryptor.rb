require 'openssl'
require 'base64'

class Encryptor
  def self.encrypt(user_email, identifier)
    plain_text = "#{user_email}--#{identifier}"
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

  def self.encrypt_for_message(message_uuid, message_change_notifier_uuid)
    plain_text = "#{message_uuid}--#{message_change_notifier_uuid}"
    cipher = configure
    ciphertext = cipher.update(plain_text)
    ciphertext.<<(cipher.final)
    encoded_cipher_text = Base64.strict_encode64(ciphertext)
    CGI.escape(encoded_cipher_text)
  end

  def self.encrypt_for_template(data)
    raise "Invalid data object. Please pass in a hash" if(data.blank? || !data.instance_of?(Hash))
    verifier = ActiveSupport::MessageVerifier.new(SiteConfig.template_encryption_secret)
    verifier.generate(data.to_json)
  end

  def self.decrypt_for_template(token)
    verifier = ActiveSupport::MessageVerifier.new(SiteConfig.template_encryption_secret)
    JSON.parse(verifier.verify(token))
    rescue Exception => e
    p "ERROR ==> #{e.message}"
    p "ERROR ==> #{e.backtrace}"
    return false
  end

  def self.encrypt_for_edit_message(access_token, manager_uuid, message_uuid, message_change_notifier_uuid)
    plain_text = "#{access_token}--#{manager_uuid}--#{message_uuid}--#{message_change_notifier_uuid}"
    cipher = configure
    ciphertext = cipher.update(plain_text)
    ciphertext.<<(cipher.final)
    encoded_cipher_text = Base64.strict_encode64(ciphertext)
    CGI.escape(encoded_cipher_text)
  end
end
