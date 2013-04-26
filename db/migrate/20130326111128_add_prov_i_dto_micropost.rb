class AddProvIDtoMicropost < ActiveRecord::Migration
  def change
  	add_column :microposts, :prov_id, :int
  end
end
