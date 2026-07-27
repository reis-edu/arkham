require 'rails_helper'

RSpec.describe Arkham::Presenters::PatientPresenter do
  let(:get_presigned_profile_url_use_case) { instance_double('Arkham::UseCases::GetPresignedProfileUrl') }

  describe '#to_json' do
    context 'when patient has a photo' do
      let(:patient) do
        instance_double(
          'Arkham::Domain::Entities::Patient',
          id: 1,
          firstname: 'John',
          lastname: 'Doe',
          fullname: 'John Doe',
          cpf: '123.456.789-00',
          gender: 'm',
          status: 'active',
          birth_date: Date.new(1990, 1, 1),
          photo_url: 'https://storage.googleapis.com/mock-bucket/mock-photo.jpg',
          photo_key: 'mock-photo-key',
          age: 36,
          active?: true
        )
      end

      it 'resolves the presigned url through the injected use case' do
        expect(get_presigned_profile_url_use_case).to receive(:execute).with('mock-photo-key').and_return('https://presigned.example.com/photo.jpg')

        presenter = described_class.new(patient, get_presigned_profile_url_use_case: get_presigned_profile_url_use_case)

        expect(presenter.to_json[:presigned_photo_url]).to eq('https://presigned.example.com/photo.jpg')
      end
    end

    context 'when patient has no photo' do
      let(:patient) do
        instance_double(
          'Arkham::Domain::Entities::Patient',
          id: 1,
          firstname: 'John',
          lastname: 'Doe',
          fullname: 'John Doe',
          cpf: '123.456.789-00',
          gender: 'm',
          status: 'active',
          birth_date: Date.new(1990, 1, 1),
          photo_url: nil,
          photo_key: nil,
          age: 36,
          active?: true
        )
      end

      it 'does not call the presigned url use case and returns nil' do
        expect(get_presigned_profile_url_use_case).not_to receive(:execute)

        presenter = described_class.new(patient, get_presigned_profile_url_use_case: get_presigned_profile_url_use_case)

        expect(presenter.to_json[:presigned_photo_url]).to be_nil
      end
    end

    context 'when not given an explicit use case' do
      let(:patient) do
        instance_double(
          'Arkham::Domain::Entities::Patient',
          id: 1,
          firstname: 'John',
          lastname: 'Doe',
          fullname: 'John Doe',
          cpf: '123.456.789-00',
          gender: 'm',
          status: 'active',
          birth_date: Date.new(1990, 1, 1),
          photo_url: nil,
          photo_key: nil,
          age: 36,
          active?: true
        )
      end

      it 'defaults to Arkham::Dependencies.get_presigned_profile_url_use_case' do
        expect(Arkham::Dependencies).to receive(:get_presigned_profile_url_use_case).and_return(get_presigned_profile_url_use_case)

        described_class.new(patient)
      end
    end
  end
end
