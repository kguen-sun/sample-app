class User < ApplicationRecord
  PERMITTED_PARAMS = %i(name email password password_validation).freeze

  attr_accessor :remember_token, :activation_token

  before_save :email_downcase
  before_create :create_activation_digest

  validates :name, presence: true,
            length: {maximum: Settings.validate.user.name_maxlength}
  validates :email, presence: true,
            length: {maximum: Settings.validate.user.email_maxlength},
            format: {with: Settings.validate.user.email_format},
            uniqueness: {case_sensitive: false}
  validates :password, presence: true,
            length: {minimum: Settings.validate.user.password_minlength},
            allow_nil: true

  has_secure_password

  paginates_per Settings.pagination.per_page

  scope :is_activated, ->{where activated: true}

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
    update remember_digest: User.digest(remember_token)
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def can_activate? token
    !activated? && authenticated?(:activation, token)
  end

  def forget
    update remember_digest: nil
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  private

  def email_downcase
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest activation_token
  end
end
