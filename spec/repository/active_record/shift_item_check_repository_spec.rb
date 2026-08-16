# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::Repository::ActiveRecord::ShiftItemCheckRepository do
  let(:repository) { described_class.new }

  describe '#snapshot_for_shift' do
    it 'creates one pending check per shift item id' do
      shift = create(:shift)
      item_one = create(:shift_item)
      item_two = create(:shift_item)

      repository.snapshot_for_shift(shift.id, [item_one.id, item_two.id])

      checks = ShiftItemCheck.where(shift_id: shift.id)
      expect(checks.count).to eq(2)
      expect(checks.pluck(:shift_item_id)).to contain_exactly(item_one.id, item_two.id)
      expect(checks.pluck(:checked).uniq).to eq([false])
      expect(checks.pluck(:review_status).uniq).to eq(['pending'])
    end

    it 'does nothing when there are no item ids' do
      shift = create(:shift)
      expect { repository.snapshot_for_shift(shift.id, []) }.not_to change(ShiftItemCheck, :count)
    end
  end

  describe '#create' do
    it 'creates a single pending check for the shift/item pair' do
      shift = create(:shift)
      shift_item = create(:shift_item)

      id = repository.create(shift.id, shift_item.id)

      check = ShiftItemCheck.find(id)
      expect(check.shift_id).to eq(shift.id)
      expect(check.shift_item_id).to eq(shift_item.id)
      expect(check.checked?).to eq(false)
      expect(check.review_status).to eq('pending')
    end

    it 'raises ShiftItemCheckInvalidError when the pair already exists (unique index)' do
      existing = create(:shift_item_check)

      expect { repository.create(existing.shift_id, existing.shift_item_id) }
        .to raise_error(Arkham::Domain::Errors::ShiftItemCheckInvalidError)
    end
  end

  describe '#destroy' do
    it 'removes the check' do
      check = create(:shift_item_check)

      repository.destroy(check.id)

      expect(ShiftItemCheck.exists?(check.id)).to eq(false)
    end
  end

  describe '#find_by_id' do
    it 'returns the matching entity with the shift item name/description' do
      shift_item = create(:shift_item, name: 'Aferir pressão', description: 'Checar PA')
      check = create(:shift_item_check, shift_item: shift_item)

      entity = repository.find_by_id(check.id)

      expect(entity.id).to eq(check.id)
      expect(entity.shift_item_name).to eq('Aferir pressão')
      expect(entity.shift_item_description).to eq('Checar PA')
    end

    it 'returns the checked_by/reviewed_by name and login when present' do
      checker = create(:user, name: 'Ana Souza', login: 'ana.souza')
      reviewer = create(:user, name: 'Bruno Lima', login: 'bruno.lima')
      check = create(:shift_item_check, :checked, checked_by: checker, reviewed_by: reviewer)

      entity = repository.find_by_id(check.id)

      expect(entity.checked_by_name).to eq('Ana Souza')
      expect(entity.checked_by_login).to eq('ana.souza')
      expect(entity.reviewed_by_name).to eq('Bruno Lima')
      expect(entity.reviewed_by_login).to eq('bruno.lima')
    end

    it 'returns nil name/login when checked_by/reviewed_by are absent' do
      check = create(:shift_item_check)

      entity = repository.find_by_id(check.id)

      expect(entity.checked_by_name).to be_nil
      expect(entity.reviewed_by_name).to be_nil
    end

    it 'returns nil when there is no match' do
      expect(repository.find_by_id(SecureRandom.uuid)).to be_nil
    end
  end

  describe '#find_by_shift_and_item' do
    it 'returns the matching entity' do
      check = create(:shift_item_check)

      entity = repository.find_by_shift_and_item(check.shift_id, check.shift_item_id)

      expect(entity.id).to eq(check.id)
    end

    it 'returns nil when there is no match' do
      shift = create(:shift)
      shift_item = create(:shift_item)

      expect(repository.find_by_shift_and_item(shift.id, shift_item.id)).to be_nil
    end
  end

  describe '#find_all_for_shift' do
    it 'returns every check for the shift' do
      shift = create(:shift)
      other_shift = create(:shift, shift_date: Date.new(2027, 1, 1))
      check_one = create(:shift_item_check, shift: shift)
      create(:shift_item_check, shift: other_shift)

      expect(repository.find_all_for_shift(shift.id).map(&:id)).to eq([check_one.id])
    end
  end

  describe '#divergences_for_shift' do
    it 'returns only checks marked as divergent for the shift' do
      shift = create(:shift)
      divergent = create(:shift_item_check, :divergent, shift: shift)
      create(:shift_item_check, shift: shift, review_status: 'confirmed')

      expect(repository.divergences_for_shift(shift.id).map(&:id)).to eq([divergent.id])
    end
  end

  describe '#update_check' do
    it 'updates the given fields' do
      check = create(:shift_item_check)
      user = create(:user)

      repository.update_check(check.id, checked: true, checked_by_id: user.id, checked_at: Time.current)

      expect(check.reload.checked?).to eq(true)
      expect(check.checked_by_id).to eq(user.id)
    end

    it 'raises ShiftItemCheckInvalidError when validation fails' do
      check = create(:shift_item_check)

      expect { repository.update_check(check.id, impossible: true, impossible_reason: nil) }
        .to raise_error(Arkham::Domain::Errors::ShiftItemCheckInvalidError)
    end
  end

  describe '#update_review' do
    it 'updates the given fields' do
      check = create(:shift_item_check)
      user = create(:user)

      repository.update_review(check.id, review_status: 'confirmed', reviewed_by_id: user.id,
                                         reviewed_at: Time.current, divergence_note: nil)

      expect(check.reload.review_status).to eq('confirmed')
      expect(check.reviewed_by_id).to eq(user.id)
    end

    it 'raises ShiftItemCheckInvalidError when validation fails' do
      check = create(:shift_item_check)

      expect { repository.update_review(check.id, review_status: 'divergent', divergence_note: nil) }
        .to raise_error(Arkham::Domain::Errors::ShiftItemCheckInvalidError)
    end
  end
end
