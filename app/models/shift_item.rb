class ShiftItem < ApplicationRecord
  has_many :shift_item_checks, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  def active?
    active
  end
end
