module Arkham
  module Presenters
    class PatientPresenter
      def initialize(patient, get_presigned_profile_url_use_case: Arkham::Dependencies.get_presigned_profile_url_use_case)
        @patient = patient
        @get_presigned_profile_url_use_case = get_presigned_profile_url_use_case
      end

      def to_json
        {
          id: @patient.id,
          firstname: @patient.firstname,
          lastname: @patient.lastname,
          fullname: @patient.fullname,
          cpf: @patient.cpf,
          gender: @patient.gender,
          status: @patient.status,
          birth_date: @patient.birth_date,
          photo_url: @patient.photo_url,
          presigned_photo_url: presigned_photo_url,
          age: @patient.age,
          active: @patient.active?
        }
      end

      private

      def presigned_photo_url
        if @patient.photo_key.present? && @patient.photo_url.present?
          @get_presigned_profile_url_use_case.execute(@patient.photo_key)
        else
          nil
        end
      end
    end
  end
end
