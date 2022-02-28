collection :@patients
attributes :id,
           :firstname,
           :lastname,
           :gender,
           :photo_url
node(:fullname) { |patient| "#{patient.firstname} #{patient.lastname}".strip }
