# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Medicament, type: :model do
  describe 'Validations' do
    it 'Create a Medicament' do
      med = build(:medicament)
      expect(med).to be_valid
    end

    it 'Create a Medicament without name attribute' do
      med = build(:medicament, name: nil)
      expect(med).to be_invalid
    end
  end
end
