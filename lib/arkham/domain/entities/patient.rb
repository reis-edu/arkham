module Arkham
  module Domain
    module Entities
      class Patient
        attr_reader :id, :firstname, :lastname, :cpf, :gender, :status, 
                    :birth_date, :photo_url, :photo_key

        def initialize(attributes = {})
          @id = attributes[:id]
          @firstname = attributes[:firstname]
          @lastname = attributes[:lastname]
          @cpf = attributes[:cpf]
          @gender = attributes[:gender]
          @status = attributes[:status] || 'active'
          @birth_date = attributes[:birth_date]
          @photo_url = attributes[:photo_url]
          @photo_key = attributes[:photo_key]
        end

        def active?
          @status == 'active'
        end

        def age
          return 0 unless @birth_date
          Date.today.year - @birth_date.year
        end

        def fullname
          "#{@firstname} #{@lastname}"
        end
      end
    end
  end
end
