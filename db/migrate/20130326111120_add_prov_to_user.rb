class AddProvToUser < ActiveRecord::Migration
  def change
  	add_column :users, :access_token, :text
  	add_column :users, :prov_username, :string
  end
end
