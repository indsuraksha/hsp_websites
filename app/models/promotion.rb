class Promotion < ActiveRecord::Base
  extend FriendlyId
  friendly_id :sanitized_name

  validates :brand_id, presence: true
  validates :name, presence: true, uniqueness: true
  has_many :product_promotions
  has_many :products, through: :product_promotions
  belongs_to :brand, touch: true

  has_attached_file :promo_form, S3_STORAGE
  do_not_validate_attachment_file_type :promo_form

  has_attached_file :tile, {
    styles: { large: "550x370",
      medium: "480x360",
      small: "240x180",
      thumb: "100x100",
      tiny: "64x64",
      tiny_square: "64x64#"
    }}.merge(S3_STORAGE)
  validates_attachment :tile, content_type: { content_type: /\Aimage/i }

  has_attached_file :homepage_banner, {
    styles: { banner: "840x390",
      large: "550x370",
      medium: "480x360",
      small: "240x180",
      thumb: "100x100",
      tiny: "64x64",
      tiny_square: "64x64#"
    }}.merge(S3_STORAGE)
  validates_attachment :homepage_banner, content_type: { content_type: /\Aimage/i }

  after_save :translate

  def sanitized_name
    self.name.gsub(/[\'\"]/, "")
  end

  # All promotions for the given Website whose "show on website" range
  # is still current. This may include promotions which are expired, but
  # are still scheduled to appear.
  #
  def self.current(website)
    where(brand_id: website.brand_id).where(["show_start_on IS NOT NULL AND show_end_on IS NOT NULL AND show_start_on <= ? AND show_end_on >= ?", Date.today, Date.today])
  end

  # Sorted collection of self.current
  #
  def self.all_for_website(website)
    current(website).order("end_on ASC")
  end

  # All CURRENT promotions (those which are not expired) for the given Website
  #
  def self.current_for_website(website)
    where(brand_id: website.brand_id).where(["show_start_on IS NOT NULL AND show_end_on IS NOT NULL AND start_on <= ? AND end_on >= ?", Date.today, Date.today]).order("end_on ASC")
  end

  # Promotions which are still scheduled to appear on the Website, but whose
  # valid period is expired.
  #
  def self.recently_expired_for_website(website)
    current(website) - current_for_website(website)
  end

  # !blank? doesn't work because tiny MCE supplies a blank line even
  # if we don't want it...
  def has_description?
    self.description.size > 28
  end

  def expired?
    (end_on <= Date.today)
  end

  # Translates this record into other languages.
  def translate
    ContentTranslation.auto_translate(self, self.brand)
  end
  handle_asynchronously :translate

end
