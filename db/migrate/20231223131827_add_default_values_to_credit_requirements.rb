class AddDefaultValuesToCreditRequirements < ActiveRecord::Migration
  def change
    change_column_default :credit_requirements, :public_mandatory_credits, 2
    change_column_default :credit_requirements, :major_credits, 12
    change_column_default :credit_requirements, :all_credits, 30
  end
end
