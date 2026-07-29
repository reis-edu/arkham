module Arkham
  module Presenters
    class UserCreatedPresenter
      def initialize(user_id)
        @user_id = user_id
      end

      def to_json
        {
          id: @user_id
        }
      end
    end
  end
end
