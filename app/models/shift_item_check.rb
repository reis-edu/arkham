class ShiftItemCheck < ApplicationRecord
  REVIEW_STATUSES = %w[pending confirmed divergent].freeze

  belongs_to :shift
  belongs_to :shift_item
  belongs_to :checked_by, class_name: 'User', optional: true
  belongs_to :reviewed_by, class_name: 'User', optional: true

  validates :review_status, presence: true, inclusion: { in: REVIEW_STATUSES }
  validates :shift_item_id, uniqueness: { scope: :shift_id }
  validates :impossible_reason, presence: true, if: :impossible?
  validates :divergence_note, presence: true, if: -> { review_status == 'divergent' }

  def checked?
    checked
  end

  def impossible?
    impossible
  end

  def divergent?
    review_status == 'divergent'
  end
end
