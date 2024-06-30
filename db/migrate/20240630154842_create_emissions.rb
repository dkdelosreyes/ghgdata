class CreateEmissions < ActiveRecord::Migration[7.0]
  def change
    create_table :emissions do |t|
      t.references :summary, null: false, foreign_key: true
      t.references :data_group, null: true, foreign_key: true

      t.string :gas
      t.float :amount

      t.timestamps
    end
  end
end
