class TrainingModule < ActiveRecord::Base
  has_many :product_training_modules, dependent: :destroy
  has_many :products, through: :product_training_modules
  has_many :software_training_modules, dependent: :destroy
  has_many :softwares, through: :software_training_modules
  belongs_to :brand
  validates :brand_id, :name, presence: true
  has_attached_file :training_module, 
    storage: :s3,
    bucket: S3_CREDENTIALS['bucket'],
    s3_credentials: S3_CREDENTIALS,
    s3_host_alias: S3_CLOUDFRONT,
    url: ':s3_domain_url',
    path: ":class/:attachment/:id_:timestamp/:basename_:style.:extension"
  validates_attachment :training_module, presence: true
  do_not_validate_attachment_file_type :training_module

  def self.modules_for(brand_id, options={})
  	collection = select("DISTINCT training_modules.*").where(brand_id: brand_id)
  	if options[:module_type]
  		collection = collection.joins("#{options[:module_type]}_training_modules".to_sym)
  	end
  	collection
  end

  def active_softwares
    self.softwares.where(active: true)
  end
end
