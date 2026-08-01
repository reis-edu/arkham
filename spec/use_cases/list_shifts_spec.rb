require 'rails_helper'

RSpec.describe Arkham::UseCases::ListShifts do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_repository) }

  describe '#execute' do
    it 'delegates to the repository and returns its result' do
      shifts = [Arkham::Domain::Entities::Shift.new(id: SecureRandom.uuid)]
      allow(shift_repository).to receive(:find_all).with({}).and_return(shifts)

      expect(use_case.execute).to eq(shifts)
    end
  end
end
