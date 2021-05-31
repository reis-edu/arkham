# frozen_string_literal: true

module Core
  module CommandHandlers
    class CreateVitalSignCommandHandler
      def initialize(repositories = {})
        @vital_sign_repository = repositories.fetch(:vital_signs) { Infra::Repositories::VitalSignRepository.new }
      end

      def execute(create_vital_sign_command)
        vital_sign = VitalSign.new(create_vital_sign_command.vital_sign)
        vital_sign.patient = create_vital_sign_command.patient
        vital_sign.save!

        vital_sign.id
      end
    end
  end
end
