class ChangeMajorIdForUsers < ActiveRecord::Migration
  def change
    rename_column :users, :temp_major_id, :major_id
  end
end
