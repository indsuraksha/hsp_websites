class OnlineRetailer < ActiveRecord::Base
  has_many :online_retailer_users, :dependent => :destroy
  has_many :users, :through => :online_retailer_users
  has_many :online_retailer_links, :conditions => "product_id IS NOT NULL", :dependent => :destroy
  has_attached_file :retailer_logo, 
    :styles => { :medium => "300x300>", :small => "175x175>", :thumb => "100x100>" },
    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
    :url => "/system/:attachment/:id/:style/:filename"

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true, :max_length => 100
  validates_presence_of :name
  validates_uniqueness_of :name
  attr_accessor :brand_link
  
  def bad_links
    @bad_links ||= OnlineRetailerLink.problems.where(:online_retailer_id => self.id)
  end
  
  # Adds a User to be able to maintain this OnlineRetailer
  def add_user(user=User.new)
    if !user.new_record?
      OnlineRetailerUser.find_or_create_by_online_retailer_id_and_user_id(self.id, user.id)
    end
  end
  
  # Retrieves a randomized list of OnlineRetailers who have a brand_link defined
  def self.random(website)
    begin
      where(:active => true).all.select{|retailer| retailer if retailer.get_brand_link(website)}.sort_by{rand}
    rescue
      []
    end
  end
  
  # Retrieves the overall link where the OnlineRetailer lists the site's Brand products.
  def get_brand_link(website)
    begin
      if @brand_link
        @brand_link
      else
        OnlineRetailerLink.find_by_online_retailer_id_and_brand_id(self.id, website.brand_id).url
      end
    rescue
      return nil 
    end    
  end
  
  # Sets the overall link where this OnlineRetailer lists this site's Brand products.

  def set_brand_link(url, website)
    if website.brand_id > 0
      br = OnlineRetailerLink.find_or_initialize_by_online_retailer_id_and_brand_id(self.id, website.brand_id)
      br.url = url
      br.save!
    else
      return false
    end
  end
  
end
