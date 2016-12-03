module LegacyPassword
  extend ActiveSupport::Concern

  def check_password(password)
    if self.legacy_password_digest
      case self.legacy_password_digest.size
      when 94
        check_legacy_password_v1(password)
      when 54
        check_legacy_password_v1(password)
      when 142
        check_legacy_password_v2(password)
      else
        false
      end
    else
      self.authenticate(password)
    end
  end

  def check_legacy_password_v1(password)
    salt = self.legacy_password_digest[6..13].scan(/../).map{|x| x.to_i(16).chr}.join
    hash = self.legacy_password_digest[14..53].downcase
    password2 = password.split(//).map{|x| x + "\x00"}.join
    if Digest::SHA512.new.update(password2 + salt) == hash
      self.update_attributes(
        legacy_password_digest: nil,
        password: password
      )
      self
    else
      false
    end
  end

  def check_legacy_password_v2(password)
    salt = self.legacy_password_digest[6..13].scan(/../).map{|x| x.to_i(16).chr}.join
    hash = self.legacy_password_digest[14..-1].downcase
    password2 = password.split(//).map{|x| x + "\x00"}.join
    if Digest::SHA512.new.update(password2 + salt) == hash
      self.update_attributes(
        legacy_password_digest: nil,
        password: password
      )
      self
    else
      false
    end
  end
end
