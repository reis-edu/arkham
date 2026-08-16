# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Arkham::Repository::ActiveRecord::PatientRepository do
  let(:repository) { described_class.new }

  describe '#create' do
    context 'when the patient params fail model validation' do
      let(:invalid_params) do
        {
          lastname: 'Doe',
          cpf: '123.456.789-00',
          gender: 'm',
          status: 'active'
        }
      end

      it 'raises Arkham::Domain::Errors::PatientInvalidError instead of ActiveRecord::RecordInvalid' do
        expect do
          repository.create(invalid_params)
        end.to raise_error(Arkham::Domain::Errors::PatientInvalidError, /Firstname/)
      end
    end
  end

  describe '#update' do
    let!(:patient) { create(:patient) }

    context 'when the update params fail model validation' do
      it 'raises Arkham::Domain::Errors::PatientInvalidError instead of ActiveRecord::RecordInvalid' do
        expect do
          repository.update(patient.id, firstname: '')
        end.to raise_error(Arkham::Domain::Errors::PatientInvalidError, /Firstname/)
      end
    end
  end
end
