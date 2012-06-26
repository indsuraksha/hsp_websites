class CreateProductPromotions < ActiveRecord::Migration
  def self.up
    create_table :product_promotions do |t|
      t.integer :product_id
      t.integer :promotion_id

      t.timestamps
    end
  end

  def self.down
    drop_table :product_promotions
  end
end
