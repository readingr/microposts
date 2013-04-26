class AddReplies < ActiveRecord::Migration
  def change
  	add_column :microposts, :in_reply_to, :int
  end
end
