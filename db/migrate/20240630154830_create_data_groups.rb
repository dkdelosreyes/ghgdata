class CreateDataGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :data_groups do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end
  end
end
