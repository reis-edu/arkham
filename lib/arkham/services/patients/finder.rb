# frozen_string_literal: true

module Services
  module Patients
    class Finder
      def self.find_patients(params)
        ::Patient.where(params).all
      end
    end
  end
end
