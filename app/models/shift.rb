class Shift < ApplicationRecord
  TYPES = %w[diurno noturno].freeze
  STATUSES = %w[open execution_finalized review_finalized].freeze

  has_many :shift_item_checks, dependent: :destroy
  belongs_to :execution_finalized_by, class_name: 'User', optional: true
  belongs_to :review_finalized_by, class_name: 'User', optional: true

  validates :shift_date, presence: true
  validates :shift_type, presence: true, inclusion: { in: TYPES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :shift_date, uniqueness: { scope: :shift_type }

  def open?
    status == 'open'
  end

  def execution_finalized?
    status == 'execution_finalized'
  end

  def review_finalized?
    status == 'review_finalized'
  end
end
