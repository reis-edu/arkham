# frozen_string_literal: true

class Patient < ApplicationRecord
  has_many :medicament_managements, dependent: :destroy
  has_many :medicaments, through: :medicament_managements

  validates :firstname,    presence: true
  validates :lastname,     presence: true
  validates :cpf,          presence: true
  validates :gender,       presence: true

  validates_uniqueness_of :cpf

  def age
    Date.today.year - birth_date.year
  end

  def fullname
    "#{firstname} #{lastname}"
  end
end
