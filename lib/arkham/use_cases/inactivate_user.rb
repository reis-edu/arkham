module Arkham
  module UseCases
    class InactivateUser
      def initialize(user_repository, ensure_privileged_group_remains = EnsurePrivilegedGroupRemains.new(user_repository))
        @user_repository = user_repository
        @ensure_privileged_group_remains = ensure_privileged_group_remains
      end

      def execute(user_id)
        @user_repository.within_transaction do
          user = @user_repository.find_by_id(user_id)
          raise Domain::Errors::UserNotFoundError, 'User not found' unless user

          @ensure_privileged_group_remains.call(user)

          @user_repository.inactivate(user_id)
        end
      end
    end
  end
end
