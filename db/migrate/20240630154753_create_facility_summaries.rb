class CreateFacilitySummaries < ActiveRecord::Migration[7.0]
  def change
    create_table :facility_summaries do |t|
      t.references :facility, null: false, foreign_key: true

      t.integer :data_year
      t.integer :total_gas_emissions

      t.timestamps
    end
  end
end
