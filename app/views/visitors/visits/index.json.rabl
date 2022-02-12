collection :@visits
attributes :id,
           :visitor_id,
           :start_date,
           :end_date,
           :description,
           :created_at,
           :updated_at

child(:patient) { attributes  :firstname,
                              :lastname,
                              :gender,
                              :photo_url }
child(:visitor) { attributes  :fullname,
                              :email }