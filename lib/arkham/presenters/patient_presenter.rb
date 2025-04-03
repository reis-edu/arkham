module Arkham
  module Presenters
    class PatientPresenter
      def initialize(patient)
        @patient = patient
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
          age: @patient.age,
          active: @patient.active?
        }
      end
    end
  end
end
