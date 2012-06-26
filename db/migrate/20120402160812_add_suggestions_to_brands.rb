class AddSuggestionsToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :has_suggested_products, :boolean
    Brand.find("lexicon").update_attributes(:has_suggested_products => true)
  end
end
