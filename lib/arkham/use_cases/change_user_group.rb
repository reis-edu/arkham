module Arkham
  module UseCases
    class ChangeUserGroup
      def initialize(user_repository, ensure_privileged_group_remains = EnsurePrivilegedGroupRemains.new(user_repository))
        @user_repository = user_repository
        @ensure_privileged_group_remains = ensure_privileged_group_remains
      end

      def execute(user_id, group_params)
        new_group = validate_group_params(group_params)[:group]

        @user_repository.within_transaction do
          user = @user_repository.find_by_id(user_id)
          raise Domain::Errors::UserNotFoundError, 'User not found' unless user

          @ensure_privileged_group_remains.call(user, new_group: new_group)

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
    end
  end
end
