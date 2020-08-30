# frozen_string_literal: true

collection :@patients
attributes :id,
           :firstname,
           :lastname,
           :gender,
           :diagnosis,
           :sus,
           :rg,
           :cpf,
           :admission_date,
           :birth_date,
           :created_at,
           :updated_at,
           :photo_url,
           :photo_key

node :age, &:age
