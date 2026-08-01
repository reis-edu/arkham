module Arkham
  module Domain
    module Entities
      class Shift
        attr_reader :id, :shift_date, :shift_type, :status, :execution_note,
                    :execution_finalized_at, :execution_finalized_by_id,
                    :review_finalized_at, :review_finalized_by_id

        def initialize(attributes = {})
          @id = attributes[:id]
          @shift_date = attributes[:shift_date]
          @shift_type = attributes[:shift_type]
          @status = attributes[:status] || 'open'
          @execution_note = attributes[:execution_note]
          @execution_finalized_at = attributes[:execution_finalized_at]
          @execution_finalized_by_id = attributes[:execution_finalized_by_id]
          @review_finalized_at = attributes[:review_finalized_at]
          @review_finalized_by_id = attributes[:review_finalized_by_id]
        end

        def open?
          @status == 'open'
        end

        def execution_finalized?
          @status == 'execution_finalized'
        end

        def review_finalized?
          @status == 'review_finalized'
        end
      end
    end
  end
end
