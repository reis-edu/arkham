module Arkham
  module UseCases
    class ListUsers
      def initialize(user_repository)
        @user_repository = user_repository
      end

      def execute(filter_params = {})
        @user_repository.find_all(filter_params)
      end
    end
  end
end
