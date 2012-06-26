class CreateRegions < ActiveRecord::Migration
  def self.up
    create_table :regions do |t|
      t.string :name
      t.string :coordinates

      t.timestamps
    end
  end

  def self.down
    drop_table :regions
  end
end
