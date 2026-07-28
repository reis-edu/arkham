module Arkham
  class Dependencies
    def self.patient_repository
      @patient_repository ||= Repository::ActiveRecord::PatientRepository.new
    end

    def self.patient_photo_repository
      @patient_photo_repository ||= Repository::Filebase::PatientPhotoRepository.new
    end

    def self.show_patient_use_case
      @show_patient_use_case ||= UseCases::ShowPatient.new(patient_repository)
    end

    def self.list_patients_use_case
      @list_patients_use_case ||= UseCases::ListPatients.new(patient_repository)
    end

    def self.save_patient_photo_use_case
      @save_patient_photo_use_case ||= UseCases::SavePatientPhoto.new(patient_repository, patient_photo_repository)
    end

    def self.create_patient_use_case
      @create_patient_use_case ||= UseCases::CreatePatient.new(patient_repository, patient_photo_repository, save_patient_photo_use_case)
    end

    def self.update_patient_use_case
      @update_patient_use_case ||= UseCases::UpdatePatient.new(patient_repository, patient_photo_repository, save_patient_photo_use_case)
    end

    def self.destroy_patient_use_case
      @destroy_patient_use_case ||= UseCases::DestroyPatient.new(patient_repository)
    end

    def self.activate_patient_use_case
      @activate_patient_use_case ||= UseCases::ActivatePatient.new(patient_repository)
    end

    def self.inactivate_patient_use_case
      @inactivate_patient_use_case ||= UseCases::InactivatePatient.new(patient_repository)
    end

    def self.get_presigned_profile_url_use_case
      @get_presigned_profile_url_use_case ||= UseCases::GetPresignedProfileUrl.new(patient_photo_repository)
    end

    def self.user_repository
      @user_repository ||= Repository::ActiveRecord::UserRepository.new
    end

    def self.refresh_token_repository
      @refresh_token_repository ||= Repository::ActiveRecord::RefreshTokenRepository.new
    end

    def self.issue_token_pair_use_case
      @issue_token_pair_use_case ||= UseCases::IssueTokenPair.new(refresh_token_repository)
    end

    def self.create_user_use_case
      @create_user_use_case ||= UseCases::CreateUser.new(user_repository)
    end

    def self.login_use_case
      @login_use_case ||= UseCases::Login.new(user_repository, issue_token_pair_use_case)
    end

    def self.refresh_access_token_use_case
      @refresh_access_token_use_case ||= UseCases::RefreshAccessToken.new(user_repository, refresh_token_repository, issue_token_pair_use_case)
    end

    def self.change_password_use_case
      @change_password_use_case ||= UseCases::ChangePassword.new(user_repository)
    end

    def self.change_user_group_use_case
      @change_user_group_use_case ||= UseCases::ChangeUserGroup.new(user_repository)
    end
  end
end
