# frozen_string_literal: true

module Services
  module Patients
    class Finder
      def self.resumed_list
        ::Patient.select(:id, :firstname, :lastname, :gender, :photo_url).where(status: :active)
      end

      def self.find_patients(params)
        ::Patient.where(params).all
      end
    end
  end
end
