class VitalSign < ApplicationRecord
  belongs_to :patient

  validates :date,    presence: true
  validates :period,  presence: true, inclusion: { in: %w[morning evening night] }
end
