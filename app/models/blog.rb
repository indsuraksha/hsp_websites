class Blog < ActiveRecord::Base
  belongs_to :brand
  has_many :blog_articles
  validates :brand_id, presence: true
  validates :name, presence: true, uniqueness: true
  has_friendly_id :sanitized_name, use_slug: true, approximate_ascii: true, max_length: 100
  
  def sanitized_name
    self.name.gsub(/[\'\"]/, "")
  end
  
  def published_articles
    blog_articles.where(["publish_on <= ?", Date.today]).order("publish_on DESC")
  end
  
  def layout
    blog_custom = Rails.root.join("app", "views", brand.folder, "layouts", "#{self.friendly_id}.html.erb")
    brand_custom = Rails.root.join("app", "views", brand.folder, "layouts", "application.html.erb")
    if File.exists?(blog_custom)
      blog_custom
    elsif File.exists(brand_custom)
      brand_custom
    else
      Rails.root.join("app", "views", "layouts", "application.html.erb")
    end
  end
end
