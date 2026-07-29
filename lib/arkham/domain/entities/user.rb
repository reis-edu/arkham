module Arkham
  module Domain
    module Entities
      class User
        attr_reader :id, :name, :login, :email, :group, :active, :must_change_password

        def initialize(attributes = {})
          @id = attributes[:id]
          @name = attributes[:name]
          @login = attributes[:login]
          @email = attributes[:email]
          @group = attributes[:group]
          @active = attributes[:active]
          @must_change_password = attributes[:must_change_password]
        end

        def active?
          @active
        end

        def maintainer_or_administrator?
          %w[maintainer administrator].include?(@group)
        end
      end
    end
  end
end
