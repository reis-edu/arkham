module Arkham
  module UseCases
    class EnsurePrivilegedGroupRemains
      def initialize(user_repository)
        @user_repository = user_repository
      end

      # Called whenever a user may leave the privileged group (change of group,
      # inactivation or removal). Skipped entirely when the user isn't currently
      # privileged, or when a group change promotes them to a privileged group.
      def call(user, new_group: nil)
        return if new_group && ::User::PRIVILEGED_GROUPS.include?(new_group)
        return unless ::User::PRIVILEGED_GROUPS.include?(user.group)

        remaining = @user_repository.count_active_in_groups(::User::PRIVILEGED_GROUPS, excluding_user_id: user.id)
        return unless remaining.zero?

        raise Domain::Errors::LastAdministratorError, 'At least one active administrator or maintainer must remain'
      end
    end
  end
end
