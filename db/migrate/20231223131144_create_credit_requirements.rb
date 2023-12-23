class CreateCreditRequirements < ActiveRecord::Migration
  def change
    create_table :credit_requirements do |t|
      t.references :major, index: true, foreign_key: true
      t.integer :public_mandatory_credits
      t.integer :major_credits
      t.integer :all_credits

      t.timestamps null: false
    end
  end
end
