# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::Repository::ActiveRecord::ShiftRepository do
  let(:repository) { described_class.new }

  describe '#create' do
    it 'creates the record and returns its id' do
      id = repository.create(shift_date: Date.new(2026, 7, 28), shift_type: 'diurno')
      expect(Shift.exists?(id)).to eq(true)
    end

    it 'creates the record with a title' do
      id = repository.create(shift_date: Date.new(2026, 7, 28), shift_type: 'diurno', title: 'Ala feminina')
      expect(Shift.find(id).title).to eq('Ala feminina')
    end

    it 'allows creating more than one shift for the same date and type' do
      create(:shift, shift_date: Date.new(2026, 7, 28), shift_type: 'diurno')

      id = repository.create(shift_date: Date.new(2026, 7, 28), shift_type: 'diurno')
      expect(Shift.exists?(id)).to eq(true)
    end
  end

  describe '#find_all' do
    it 'returns all shifts ordered by shift_date descending' do
      older = create(:shift, shift_date: Date.new(2026, 1, 1))
      newer = create(:shift, shift_date: Date.new(2026, 2, 1))

      expect(repository.find_all.map(&:id)).to eq([newer.id, older.id])
    end
  end

  describe '#find_by_id' do
    it 'returns the matching entity' do
      shift = create(:shift)
      expect(repository.find_by_id(shift.id).id).to eq(shift.id)
    end

    it 'returns nil when there is no match' do
      expect(repository.find_by_id(SecureRandom.uuid)).to be_nil
    end
  end

  describe '#find_last_by_type' do
    it 'returns the most recent shift of the given type' do
      create(:shift, shift_date: Date.new(2026, 1, 1), shift_type: 'noturno')
      most_recent = create(:shift, shift_date: Date.new(2026, 2, 1), shift_type: 'noturno')
      create(:shift, shift_date: Date.new(2026, 3, 1), shift_type: 'diurno')

      expect(repository.find_last_by_type('noturno').id).to eq(most_recent.id)
    end

    it 'returns nil when there is no shift of that type' do
      create(:shift, shift_date: Date.new(2026, 1, 1), shift_type: 'diurno')

      expect(repository.find_last_by_type('noturno')).to be_nil
    end
  end

  describe '#find_current' do
    it 'returns the most recent shift that is not review_finalized' do
      create(:shift, :review_finalized, shift_date: Date.new(2026, 5, 1))
      current = create(:shift, shift_date: Date.new(2026, 4, 1), status: 'open')

      expect(repository.find_current.id).to eq(current.id)
    end

    it 'falls back to the most recent shift overall when all are review_finalized' do
      older = create(:shift, :review_finalized, shift_date: Date.new(2026, 1, 1))
      newest = create(:shift, :review_finalized, shift_date: Date.new(2026, 2, 1))

      expect(repository.find_current.id).to eq(newest.id)
      expect(repository.find_current.id).not_to eq(older.id)
    end

    it 'returns nil when there are no shifts' do
      expect(repository.find_current).to be_nil
    end
  end

  describe '#update' do
    it 'updates the given fields' do
      shift = create(:shift, shift_type: 'diurno')
      repository.update(shift.id, shift_type: 'noturno')

      expect(shift.reload.shift_type).to eq('noturno')
    end
  end

  describe '#destroy' do
    it 'removes the shift and cascades its checks' do
      shift = create(:shift)
      check = create(:shift_item_check, shift: shift)

      repository.destroy(shift.id)

      expect(Shift.exists?(shift.id)).to eq(false)
      expect(ShiftItemCheck.exists?(check.id)).to eq(false)
    end
  end

  describe '#finalize_execution' do
    it 'finalizes the execution phase' do
      shift = create(:shift)
      user = create(:user)

      repository.finalize_execution(shift.id, execution_note: 'Tudo certo', by_id: user.id)
      shift.reload

      expect(shift.status).to eq('execution_finalized')
      expect(shift.execution_note).to eq('Tudo certo')
      expect(shift.execution_finalized_by_id).to eq(user.id)
      expect(shift.execution_finalized_at).to be_present
    end
  end

  describe '#finalize_review' do
    it 'finalizes the review phase' do
      shift = create(:shift, :execution_finalized)
      user = create(:user)

      repository.finalize_review(shift.id, by_id: user.id)
      shift.reload

      expect(shift.status).to eq('review_finalized')
      expect(shift.review_finalized_by_id).to eq(user.id)
      expect(shift.review_finalized_at).to be_present
    end
  end
end
