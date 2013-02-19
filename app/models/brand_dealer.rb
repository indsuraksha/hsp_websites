class BrandDealer < ActiveRecord::Base
  attr_accessible :brand_id, :dealer_id
  belongs_to :brand 
  belongs_to :dealer 
  validates :brand_id, presence: true 
  validates :dealer_id, presence: true, uniqueness: { scope: :brand_id }
end