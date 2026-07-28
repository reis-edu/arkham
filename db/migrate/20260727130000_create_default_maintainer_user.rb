class CreateDefaultMaintainerUser < ActiveRecord::Migration[8.0]
  DEFAULT_LOGIN = 'admin.sistema'

  # Bootstraps the first maintainer account so a fresh deploy always has at
  # least one user able to create/manage other users. Runs once (standard
  # Rails migration semantics): if this user is later removed, it will not
  # be recreated automatically.
  def up
    return if User.exists?(login: DEFAULT_LOGIN)

    User.create!(
      name: 'Administrador do Sistema',
      login: DEFAULT_LOGIN,
      email: 'admin@arkham.local',
      group: 'maintainer',
      password: Arkham.config[:users][:default_password],
      active: true,
      must_change_password: true
    )
  end

  def down
    User.find_by(login: DEFAULT_LOGIN)&.destroy
  end
end
