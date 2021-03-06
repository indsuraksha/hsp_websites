class ProductStatus < ActiveRecord::Base
  has_many :products

  def is_current?
    self.show_on_website && !self.discontinued
  end

  def is_discontinued?
    self.discontinued
  end

  def in_development?
    self.is_hidden? && !self.is_discontinued?
  end

  def is_hidden?
    !self.show_on_website
  end

  def in_production?
    is_current? && self.shipping
  end

  def not_supported?
    !self.show_on_website || self.vintage?
  end

  def vintage?
    !!(self.name.match(/vintage/i))
  end
 
end
