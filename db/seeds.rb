# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

maintainer_login = ENV.fetch('ARKHAM_SEED_MAINTAINER_LOGIN', 'admin.sistema')
maintainer_name  = ENV.fetch('ARKHAM_SEED_MAINTAINER_NAME', 'Administrador do Sistema')
maintainer_email = ENV.fetch('ARKHAM_SEED_MAINTAINER_EMAIL', 'admin@arkham.local')

User.find_or_create_by!(login: maintainer_login) do |user|
  user.name = maintainer_name
  user.email = maintainer_email
  user.group = 'maintainer'
  user.password = Arkham.config[:users][:default_password]
  user.active = true
  user.must_change_password = true
end
