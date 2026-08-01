require 'rails_helper'

RSpec.describe Arkham::Repository::ActiveRecord::ShiftItemRepository do
  let(:repository) { described_class.new }

  describe '#create' do
    it 'creates the record and returns its id' do
      id = repository.create(name: 'Aferir pressão', description: 'Checar PA')
      expect(ShiftItem.exists?(id)).to eq(true)
    end

    it 'raises ShiftItemInvalidError when validation fails' do
      expect { repository.create(name: nil) }.to raise_error(Arkham::Domain::Errors::ShiftItemInvalidError)
    end
  end

  describe '#find_all' do
    it 'returns all shift items ordered by name' do
      create(:shift_item, name: 'Zelar higiene')
      create(:shift_item, name: 'Aferir pressão')

      expect(repository.find_all.map(&:name)).to eq(['Aferir pressão', 'Zelar higiene'])
    end
  end

  describe '#find_all_active' do
    it 'returns only active shift items' do
      active_item = create(:shift_item, name: 'Ativo')
      create(:shift_item, :inactive, name: 'Inativo')

      expect(repository.find_all_active.map(&:id)).to eq([active_item.id])
    end
  end

  describe '#find_by_id' do
    it 'returns the matching entity' do
      shift_item = create(:shift_item)
      expect(repository.find_by_id(shift_item.id).id).to eq(shift_item.id)
    end

    it 'returns nil when there is no match' do
      expect(repository.find_by_id(SecureRandom.uuid)).to be_nil
    end
  end

  describe '#find_by_name' do
    it 'returns the matching entity' do
      shift_item = create(:shift_item, name: 'Trocar curativo')
      expect(repository.find_by_name('Trocar curativo').id).to eq(shift_item.id)
    end

    it 'returns nil when there is no match' do
      expect(repository.find_by_name('não existe')).to be_nil
    end
  end

  describe '#update' do
    it 'updates the given fields' do
      shift_item = create(:shift_item, active: true)
      repository.update(shift_item.id, active: false)

      expect(shift_item.reload.active?).to eq(false)
    end

    it 'raises ShiftItemInvalidError when validation fails' do
      shift_item = create(:shift_item)
      expect { repository.update(shift_item.id, name: nil) }.to raise_error(Arkham::Domain::Errors::ShiftItemInvalidError)
    end
  end

  describe '#destroy' do
    it 'removes the record when it is not used in any shift' do
      shift_item = create(:shift_item)
      repository.destroy(shift_item.id)

      expect(ShiftItem.exists?(shift_item.id)).to eq(false)
    end

    it 'raises ShiftItemInUseError when the item is used in a shift' do
      shift_item = create(:shift_item)
      create(:shift_item_check, shift_item: shift_item)

      expect { repository.destroy(shift_item.id) }.to raise_error(Arkham::Domain::Errors::ShiftItemInUseError)
    end
  end

  describe '#used_in_any_shift?' do
    it 'returns true when there is at least one check for the item' do
      shift_item = create(:shift_item)
      create(:shift_item_check, shift_item: shift_item)

      expect(repository.used_in_any_shift?(shift_item.id)).to eq(true)
    end

    it 'returns false otherwise' do
      shift_item = create(:shift_item)
      expect(repository.used_in_any_shift?(shift_item.id)).to eq(false)
    end
  end

  describe '#all_exist?' do
    it 'returns true when every given id exists' do
      item_one = create(:shift_item)
      item_two = create(:shift_item)

      expect(repository.all_exist?([item_one.id, item_two.id])).to eq(true)
    end

    it 'returns false when at least one id does not exist' do
      item_one = create(:shift_item)

      expect(repository.all_exist?([item_one.id, SecureRandom.uuid])).to eq(false)
    end

    it 'tolerates duplicate ids in the input' do
      item_one = create(:shift_item)

      expect(repository.all_exist?([item_one.id, item_one.id])).to eq(true)
    end
  end
end
