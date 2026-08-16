# frozen_string_literal: true

module Arkham
  module Repository
    module ActiveRecord
      class PatientFilterRepository
        AVAILABLE_STATUS = %w[active inactive].freeze

        def call(search_params)
          @relation = ::Patient.all
          @params = search_params

          filter_by_name
          filter_by_status

          @relation
        end

        private

        def filter_by_name
          return unless @params[:search_term].present?

          term = "%#{@params[:search_term]}%"
          @relation = @relation.where("unaccent(firstname || ' ' || lastname) ILIKE unaccent(?)", term)
        end

        def filter_by_status
          @relation = if @params[:status].present? && AVAILABLE_STATUS.include?(@params[:status])
                        @relation.where('status = ?', @params[:status])
                      else
                        @relation.where("status = 'active'")
                      end
        end
      end
    end
  end
end
