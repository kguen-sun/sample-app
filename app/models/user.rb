class User < ApplicationRecord
  PERMITTED_PARAMS = %i(name email password password_validation).freeze

  attr_accessor :remember_token

  validates :name, presence: true,
            length: {maximum: Settings.validate.user.name_maxlength}
  validates :email, presence: true,
            length: {maximum: Settings.validate.user.email_maxlength},
            format: {with: Settings.validate.user.email_format},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.validate.user.password_minlength}

  has_secure_password

  before_save :email_downcase

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost: cost
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false unless remember_digest

    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  private

  def email_downcase
    email.downcase!
  end
end
