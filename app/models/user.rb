class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
                                  foreign_key: :follower_id,
                                  dependent: :destroy,
                                  inverse_of: :follower
  has_many :passive_relationships, class_name: Relationship.name,
                                   foreign_key: :followed_id,
                                   dependent: :destroy,
                                   inverse_of: :followed
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships

  PERMITTED_PARAMS = %i(name email password password_confirmation).freeze

  attr_accessor :remember_token, :activation_token, :reset_token

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

  def forget
    update remember_digest: nil
  end

  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false unless digest

    BCrypt::Password.new(digest).is_password? token
  end

  def can_activate? token
    !activated? && authenticated?(:activation, token)
  end

  def can_reset_password? token
    activated? && authenticated?(:reset, token)
  end

  def password_reset_expired?
    reset_sent_at < Settings.validate.user.password_reset_expired.hours.ago
  end

  def following? other_user
    following.include? other_user
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def activate
    update activated: true, activated_at: Time.zone.now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now
  end

  def feed
    Micropost.users_feed following_ids << id
  end

  def follow other_user
    following << other_user
  end

  def unfollow other_user
    following.delete other_user
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
