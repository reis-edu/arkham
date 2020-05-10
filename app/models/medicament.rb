class Medicament < ApplicationRecord
  has_many :medicament_managements
  has_many :patients, through: :medicament_managements

  validates :name,    presence: true

  before_destroy :check_for_medicament_managements

  def check_for_medicament_managements
    if self.patients.count > 0
      self.errors.add(:orders, :invalid, { message: "This medicament could not be destroyed because it has associated patients" })
      raise ActiveRecord::Rollback
    end
  end
end
