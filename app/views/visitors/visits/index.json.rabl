collection :@visits
attributes :id,
           :visitor_id,
           :description,
           :created_at,
           :updated_at

node(:start_date) { |visit| visit.start_date.strftime('%a, %d %b %Y %H:%M:%S') }
node(:end_date) { |visit| visit.end_date.strftime('%a, %d %b %Y %H:%M:%S') }

child(:patient) { attributes  :firstname,
                              :lastname,
                              :gender,
                              :photo_url }
child(:visitor) { attributes  :firstname,
                              :lastname,
                              :email }