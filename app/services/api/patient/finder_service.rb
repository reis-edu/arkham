# frozen_string_literal: true

module Api
  module Patient
    class FinderService
      def self.find_patients(params)
        ::Patient.where(params).all
      end
    end
  end
end
