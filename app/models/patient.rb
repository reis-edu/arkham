class Patient < ApplicationRecord
  has_many :medicament_managements, :dependent => :destroy
  has_many :medicaments, through: :medicament_managements

  validates :name,    presence: true
  validates :cpf,     presence: true

  def age
    Date.today.year - self.birth_date.year
  end
end