class Patient < ApplicationRecord
  has_many :medicament_managements, :dependent => :destroy
  has_many :medicaments, through: :medicament_managements

  validates :firstname,    presence: true
  validates :lastname,     presence: true
  validates :cpf,          presence: true
  validates :gender,       presence: true

  validates_uniqueness_of :cpf

  attr_reader :age, :fullname

  def age
    Date.today.year - self.birth_date.year
  end

  def fullname
    "#{self.firstname} #{self.lastname}"
  end
end