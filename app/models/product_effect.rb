class ProductEffect < ActiveRecord::Base
  belongs_to :product, touch: true
  belongs_to :effect
  validates :product_id, presence: true
  validates :effect_id, presence: true, uniqueness: { scope: :product_id }
end
