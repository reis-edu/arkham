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

    def self.list_users_use_case
      @list_users_use_case ||= UseCases::ListUsers.new(user_repository)
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

    def self.destroy_user_use_case
      @destroy_user_use_case ||= UseCases::DestroyUser.new(user_repository)
    end

    def self.inactivate_user_use_case
      @inactivate_user_use_case ||= UseCases::InactivateUser.new(user_repository)
    end

    def self.shift_item_repository
      @shift_item_repository ||= Repository::ActiveRecord::ShiftItemRepository.new
    end

    def self.shift_repository
      @shift_repository ||= Repository::ActiveRecord::ShiftRepository.new
    end

    def self.shift_item_check_repository
      @shift_item_check_repository ||= Repository::ActiveRecord::ShiftItemCheckRepository.new
    end

    def self.list_shift_items_use_case
      @list_shift_items_use_case ||= UseCases::ListShiftItems.new(shift_item_repository)
    end

    def self.show_shift_item_use_case
      @show_shift_item_use_case ||= UseCases::ShowShiftItem.new(shift_item_repository)
    end

    def self.create_shift_item_use_case
      @create_shift_item_use_case ||= UseCases::CreateShiftItem.new(shift_item_repository)
    end

    def self.update_shift_item_use_case
      @update_shift_item_use_case ||= UseCases::UpdateShiftItem.new(shift_item_repository)
    end

    def self.destroy_shift_item_use_case
      @destroy_shift_item_use_case ||= UseCases::DestroyShiftItem.new(shift_item_repository)
    end

    def self.list_shift_item_checks_use_case
      @list_shift_item_checks_use_case ||= UseCases::ListShiftItemChecks.new(shift_item_check_repository)
    end

    def self.list_shifts_use_case
      @list_shifts_use_case ||= UseCases::ListShifts.new(shift_repository)
    end

    def self.show_shift_use_case
      @show_shift_use_case ||= UseCases::ShowShift.new(shift_repository, shift_item_check_repository, list_shift_item_checks_use_case)
    end

    def self.show_current_shift_use_case
      @show_current_shift_use_case ||= UseCases::ShowCurrentShift.new(shift_repository, shift_item_check_repository, list_shift_item_checks_use_case)
    end

    def self.create_shift_use_case
      @create_shift_use_case ||= UseCases::CreateShift.new(shift_repository, shift_item_repository, shift_item_check_repository)
    end

    def self.copy_last_shift_use_case
      @copy_last_shift_use_case ||= UseCases::CopyLastShift.new(shift_repository, shift_item_repository, shift_item_check_repository)
    end

    def self.update_shift_use_case
      @update_shift_use_case ||= UseCases::UpdateShift.new(shift_repository)
    end

    def self.destroy_shift_use_case
      @destroy_shift_use_case ||= UseCases::DestroyShift.new(shift_repository)
    end

    def self.check_shift_item_use_case
      @check_shift_item_use_case ||= UseCases::CheckShiftItem.new(shift_item_check_repository, shift_repository)
    end

    def self.review_shift_item_use_case
      @review_shift_item_use_case ||= UseCases::ReviewShiftItem.new(shift_item_check_repository, shift_repository)
    end

    def self.finalize_shift_execution_use_case
      @finalize_shift_execution_use_case ||= UseCases::FinalizeShiftExecution.new(shift_repository)
    end

    def self.finalize_shift_review_use_case
      @finalize_shift_review_use_case ||= UseCases::FinalizeShiftReview.new(shift_repository)
    end

    def self.list_shift_divergences_use_case
      @list_shift_divergences_use_case ||= UseCases::ListShiftDivergences.new(shift_item_check_repository, shift_repository)
    end

    def self.add_shift_item_use_case
      @add_shift_item_use_case ||= UseCases::AddShiftItem.new(shift_repository, shift_item_repository, shift_item_check_repository)
    end

    def self.remove_shift_item_use_case
      @remove_shift_item_use_case ||= UseCases::RemoveShiftItem.new(shift_repository, shift_item_check_repository)
    end
  end
end
