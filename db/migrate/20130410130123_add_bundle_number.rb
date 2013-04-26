class AddBundleNumber < ActiveRecord::Migration
  def change
  	add_column :microposts, :bundle_number, :int
  end
end
