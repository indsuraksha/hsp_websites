class UsRepRegion < ActiveRecord::Base
  # attr_accessible :brand_id, :us_region_id, :us_rep_id
  validates :brand_id, presence: true
  validates :us_region_id, presence: true
  validates :us_rep_id, presence: true
  belongs_to :us_rep 
  belongs_to :us_region 
  belongs_to :brand
  accepts_nested_attributes_for :us_region, reject_if: :all_blank
end
