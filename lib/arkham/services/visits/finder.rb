# frozen_string_literal: true

module Services
  module Visits
    class Finder
      def self.find_visits(params)
        ::Visit.where(params).all
      end

      def self.find(id)
        ::Visit.find(id)
      end
    end
  end
end
