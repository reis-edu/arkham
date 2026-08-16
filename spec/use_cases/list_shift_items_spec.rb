# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::UseCases::ListShiftItems do
  let(:shift_item_repository) { instance_double(Arkham::Repository::ActiveRecord::ShiftItemRepository) }
  let(:use_case) { described_class.new(shift_item_repository) }

  describe '#execute' do
    it 'delegates to the repository and returns its result' do
      shift_items = [Arkham::Domain::Entities::ShiftItem.new(id: SecureRandom.uuid)]
      allow(shift_item_repository).to receive(:find_all).with({}).and_return(shift_items)

      expect(use_case.execute).to eq(shift_items)
    end
  end
end
