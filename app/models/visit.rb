class Visit < ApplicationRecord
  belongs_to :visitor
  belongs_to :patient

  def self.fetch_conflicting_visits(visit)
    query = where(start_date: visit.start_date..visit.end_date)
            .or(where(end_date: visit.start_date..visit.end_date))
    query = query.where.not(id: visit.id) if visit.persisted?

    query.take
  end
end
