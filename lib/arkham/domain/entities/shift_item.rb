# frozen_string_literal: true

module Arkham
  module Domain
    module Entities
      class ShiftItem
        attr_reader :id, :name, :description, :active

        def initialize(attributes = {})
          @id = attributes[:id]
          @name = attributes[:name]
          @description = attributes[:description]
          @active = attributes[:active]
        end

        def active?
          @active
        end
      end
    end
  end
end
