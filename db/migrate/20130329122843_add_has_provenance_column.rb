class AddHasProvenanceColumn < ActiveRecord::Migration
  def change
  	add_column :microposts, :has_provenance, :string
  	remove_column :microposts, :prov_id
  end
end
