require_relative '../port'

module Arkham
  module Repository
    module ActiveRecord
      class UserRepository
        include Arkham::Repository::Port

        def within_transaction(&block)
          ::ActiveRecord::Base.transaction do
            yield if block_given?
          end
        end

        def find_by_id(user_id)
          user = ::User.find_by(id: user_id)
          return nil unless user

          map_to_entity(user)
        end

        def find_by_login(login)
          user = ::User.find_by(login: login)
          return nil unless user

          map_to_entity(user)
        end

        def create(user_params)
          user = ::User.create!(user_params)
          user.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::UserInvalidError, e.record.errors.full_messages.join(', ')
        end

        def update_password(user_id, new_password)
          user = ::User.find(user_id)
          user.update!(password: new_password, must_change_password: false)
          user.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::UserInvalidError, e.record.errors.full_messages.join(', ')
        end

        def update_group(user_id, new_group)
          user = ::User.find(user_id)
          user.update!(group: new_group)
          user.id
        rescue ::ActiveRecord::RecordInvalid => e
          raise Domain::Errors::UserInvalidError, e.record.errors.full_messages.join(', ')
        end

        def authenticate(login, password)
          user = ::User.find_by(login: login)
          return nil unless user
          return nil unless user.authenticate(password)

          map_to_entity(user)
        end

        def verify_password(user_id, password)
          user = ::User.find_by(id: user_id)
          return false unless user

          !!user.authenticate(password)
        end

        def count_active_in_groups(groups, excluding_user_id: nil)
          scope = ::User.active.with_group(groups).lock('FOR UPDATE')
          scope = scope.where.not(id: excluding_user_id) if excluding_user_id
          scope.pluck(:id).size
        end

        private

        def map_to_entity(user)
          Arkham::Domain::Entities::User.new(
            id: user.id,
            name: user.name,
            login: user.login,
            email: user.email,
            group: user.group,
            active: user.active,
            must_change_password: user.must_change_password
          )
        end
      end
    end
  end
end
