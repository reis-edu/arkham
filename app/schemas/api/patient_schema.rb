module Api
	PatientSchema = Arkham.JsonSchema do
		required(:name).filled(:str?)
	end
end