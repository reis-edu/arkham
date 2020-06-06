# frozen_string_literal: true

class MedicamentManagement < ApplicationRecord
  belongs_to :medicament
  belongs_to :patient
end
