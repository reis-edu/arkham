require 'google/cloud/storage'

class PatientPhoto
  attr_reader :patient_id, :base64_image, :base64_image_format, :photo_url, :photo_key

  def initialize(patient_id, base64_image, base64_image_format = 'png')
    storage = Google::Cloud::Storage.new(
      project_id: Arkham.config[:firebase][:project_id],
      credentials: File.join(Rails.root, 'config', Arkham.config[:firebase][:auth_file_path])
    )
    @bucket = storage.bucket Arkham.config[:firebase][:bucket]
    @base64_image = base64_image
    @patient_id = patient_id
    @base64_image_format = base64_image_format
  end

  def save
    firebase_image = @bucket.create_file(StringIO.new(serialized_image), file_path, acl: file_acl)
    @photo_key = firebase_image.id
    @photo_url = firebase_image.public_url
  end

  private

  def file_path
    "#{Arkham.config[:firebase][:patient_path]}/profile-photo-#{patient_id}.#{base64_image_format}"
  end

  def file_acl
    Arkham.config[:firebase][:acl]
  end

  def serialized_image
    Base64.decode64(base64_image.split(',', 2).last)
  end
end
