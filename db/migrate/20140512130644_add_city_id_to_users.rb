class AddCityIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :city_id, :integer
  end
end
