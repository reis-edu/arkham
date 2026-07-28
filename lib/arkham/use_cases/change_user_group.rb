module Arkham
  module UseCases
    class ChangeUserGroup
      PRIVILEGED_GROUPS = %w[administrator maintainer].freeze

      def initialize(user_repository)
        @user_repository = user_repository
      end

      def execute(user_id, group_params)
        new_group = validate_group_params(group_params)[:group]

        @user_repository.within_transaction do
          user = @user_repository.find_by_id(user_id)
          raise Domain::Errors::UserNotFoundError, 'User not found' unless user

          ensure_privileged_group_remains(user, new_group)

          @user_repository.update_group(user_id, new_group)
        end
      end

      private

      def validate_group_params(params)
        result = Validators::Api::ChangeGroupContract.new.call(params)
        if result.errors.any?
          raise Validators::Errors::ApiValidationError.new(result.errors.to_h)
        end

        result.to_h
      end

      # A privileged group (administrator/maintainer) can create and promote users.
      # Losing the last one would lock the institution out of user management entirely.
      def ensure_privileged_group_remains(user, new_group)
        return if PRIVILEGED_GROUPS.include?(new_group)
        return unless PRIVILEGED_GROUPS.include?(user.group)

        remaining = @user_repository.count_active_in_groups(PRIVILEGED_GROUPS, excluding_user_id: user.id)
        if remaining.zero?
          raise Domain::Errors::LastAdministratorError, 'At least one active administrator or maintainer must remain'
        end
      end
    end
  end
end
