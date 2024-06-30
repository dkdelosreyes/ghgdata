class CreateFacilities < ActiveRecord::Migration[7.0]
  def change
    create_table :facilities do |t|
      t.string :name
      t.string :ghgrpid, null: false
      t.float :latitude
      t.float :longitude
      t.integer :naics_code

      t.timestamps
    end

    add_index :facilities, :ghgrpid, unique: true
  end
end
