class RolesUsers < ActiveRecord::Migration
  def change
    create_table :roles_users do |t|
      t.integer :user_id
      t.integer :role_id
    end
  end
end
