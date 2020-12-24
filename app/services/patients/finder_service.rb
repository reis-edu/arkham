# frozen_string_literal: true

module Patients
  class FinderService
    def self.find_patients(params)
      ::Patient.where(params).all
    end
  end
end
