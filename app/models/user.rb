class User < ApplicationRecord
  PERMITTED_PARAMS = %i(name email password password_validation).freeze

  validates :name,
            presence: true,
            length: {maximum: Settings.validate.user.name_maxlength}

  validates :email,
            presence: true,
            length: {maximum: Settings.validate.user.email_maxlength},
            format: {with: Settings.validate.user.email_format},
            uniqueness: {case_sensitive: false}

  validates :password,
            presence: true,
            length: {minimum: Settings.validate.user.password_minlength}

  has_secure_password

  before_save :email_downcase

  private

  def email_downcase
    email.downcase!
  end
end
