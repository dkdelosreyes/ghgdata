class CreateInformations < ActiveRecord::Migration[7.0]
  def change
    create_table :informations do |t|
      t.references :summary, null: false, foreign_key: true
      t.references :data_group, null: true, foreign_key: true

      t.string :label 
      t.string :value

      t.timestamps
    end
  end
end
