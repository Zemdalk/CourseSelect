class ChangeCreditTypeForCreditRequirements < ActiveRecord::Migration
  def change
    change_column :credit_requirements, :public_mandatory_credits, :float
    change_column :credit_requirements, :major_credits, :float
    change_column :credit_requirements, :all_credits, :float
  end
end
