# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::DestroyShift do
  let(:shift_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftRepository) }
  let(:use_case) { described_class.new(shift_repository) }
  let(:shift_id) { SecureRandom.uuid }
  let(:shift) { Arkham::Domain::Entities::Shift.new(id: shift_id) }

  before do
    allow(shift_repository).to receive(:within_transaction) { |&block| block.call }
  end

  describe '#execute' do
    context 'when the shift exists' do
      before do
        allow(shift_repository).to receive(:find_by_id).with(shift_id).and_return(shift)
        allow(shift_repository).to receive(:destroy).and_return(shift_id)
      end

      it 'destroys the shift' do
        expect(shift_repository).to receive(:destroy).with(shift_id)
        use_case.execute(shift_id)
      end
    end

    context 'when the shift does not exist' do
      before { allow(shift_repository).to receive(:find_by_id).and_return(nil) }

      it 'raises ShiftNotFoundError' do
        expect { use_case.execute(shift_id) }.to raise_error(Arkham::Domain::Errors::ShiftNotFoundError)
      end
    end
  end
end
