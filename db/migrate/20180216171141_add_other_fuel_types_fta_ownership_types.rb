class AddOtherFuelTypesFtaOwnershipTypes < ActiveRecord::Migration
  def change
    add_column :assets, :other_fuel_type, :string, after: :dual_fuel_type_id
    add_column :assets, :other_fta_ownership_type, :string, after: :fta_owenrship_type_id
  end
end
