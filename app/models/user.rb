class User < ApplicationRecord
  GROUPS = %w[maintainer administrator nursing_leaders nursing_team employer].freeze
  PRIVILEGED_GROUPS = %w[administrator maintainer].freeze
  SHIFT_MANAGER_GROUPS = %w[maintainer administrator nursing_leaders].freeze
  NURSING_GROUPS = %w[maintainer administrator nursing_leaders nursing_team].freeze
  LOGIN_FORMAT = /\A[a-z0-9]+(\.[a-z0-9]+)+\z/

  has_secure_password
  has_many :refresh_tokens, dependent: :destroy

  validates :name,  presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :login, presence: true, uniqueness: true, format: { with: LOGIN_FORMAT }
  validates :group, presence: true, inclusion: { in: GROUPS }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

  scope :active, -> { where(active: true) }
  scope :with_group, ->(groups) { where(group: groups) }

  def active?
    active
  end
end
