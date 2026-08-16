# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ListShiftItemChecks do
  let(:shift_item_check_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemCheckRepository) }
  let(:use_case) { described_class.new(shift_item_check_repository) }
  let(:shift_id) { SecureRandom.uuid }

  describe '#execute' do
    it 'delegates to the repository and returns its result' do
      checks = [Arkham::Domain::Entities::ShiftItemCheck.new(id: SecureRandom.uuid)]
      allow(shift_item_check_repository).to receive(:find_all_for_shift).with(shift_id).and_return(checks)

      expect(use_case.execute(shift_id)).to eq(checks)
    end
  end
end
