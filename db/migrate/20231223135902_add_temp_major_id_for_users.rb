class AddTempMajorIdForUsers < ActiveRecord::Migration
  def change
    add_column :users, :temp_major_id, :integer
  end
end
