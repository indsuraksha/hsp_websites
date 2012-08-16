# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def cached_meta_tags
    @page_description ||= website.value_for('default_meta_tag_description') 
    @page_keywords ||= website.value_for("default_meta_tag_keywords") 
    display_meta_tags site: Setting.site_name(website)
  end

  # Generates a slideshow based on a provided list of slides and
  # an optional duration. Each slide needs to respond to:
  #   .string_value  (with the URL to link to or blank for no link.
  #                   If the string_value starts with a slash (/),
  #                   then that is the absolute URL that will be used.
  #                   Otherwise, the locale from the current HTTP
  #                   request will be prepended to the URL.)
  #   .slide  (a Paperclip::Attachment)
  # 
  # (Note: if only one slide is in the Array, then a single image
  # is rendered without the animation javascript.)
  #
  def slideshow(options={})
    default_options = { duration: 7000, slides: [], transition: "toggle" }
    options = default_options.merge(options)
    html = ''
    if options[:slides].size > 1
      html += slideshow_controls(options)
      options[:slides].each_with_index do |slide,i|
        html += slideshow_frame(slide, i)
      end
      raw(html + javascript_tag("start_slideshow(1, #{options[:slides].size}, #{options[:duration]}, '#{options[:transition]}');"))
    else
      raw(slideshow_frame(options[:slides].first))
    end
  end
  
  # Used by the "slideshow" method to render a frame
  def slideshow_frame(slide, position=0)
    hidden = (position == 0) ? "" : "display:none"
    slide_link = (slide.string_value =~ /^\// || slide.string_value =~ /^http/i) ? slide.string_value : "/#{params[:locale]}/#{slide.string_value}"
    content_tag(:div, id: "slideshow_#{(position + 1)}", class: "slideshow_frame", style: hidden) do
      (slide.string_value.blank?) ? 
        image_tag(slide.slide.url) : 
        link_to(image_tag(slide.slide.url), slide_link)
    end
  end
  
  # Controls for the generated slideshow
  def slideshow_controls(options={})
    default_options = { duration: 6000, slides: [] }
    options = default_options.merge(options)
    unless options[:slides].size <= 1
      divs = ""
      (1..options[:slides].size).to_a.reverse.each do |i|
        divs += link_to_function(i, 
                  "stop_slideshow(#{i}, #{options[:slides].size});", 
                  id: "slideshow_control_#{i}",
                  class: (i==1) ? "current_button" : "")
      end
      content_tag(:div, id: "slideshow_controls") do
        raw(divs)
      end
    end
  end

  # Generates social media links. Accepts a list of different
  # types of links. Looks for the related Setting and matching
  # image and puts them together.
  #
  def social_media_links(*networks)
    html = ''
    networks.to_a.each do |n|
      if n == 'rss'
        html += link_to(image_tag("#{n}.png", style: "vertical-align: middle;", size: "21x20"), rss_url(format: "xml"), target: "_blank")
      elsif v = website.value_for(n)
        v = (v =~ /^http/i) ? v : "http://www.#{n}.com/#{v}"
        html += link_to(image_tag("#{n}.png", style: "vertical-align: middle", size: "21x20"), v, target: "_blank")
      end
    end
    raw(html)
  end  
  
  # Remove HTML from a string (helpful for truncated intros of 
  # pre-formatted HTML)
  def strip_html(string="")
    begin
      string = string.gsub(/<\/?[^>]*>/,  "")
      string = string.gsub(/\&+\w*\;/, " ") # replace &nbsp; with a space
      string.html_safe
    rescue
      raw("<!-- error stripping html from: #{string} -->")
    end
  end

  # Capitalize the first letter of each word in a phrase
  def ucfirst(my_string)
    raw(my_string.split(" ").each{|word| word.capitalize!}.join(" "))
  end
  
  # Figure out what the link to a give Page should be
  def page_link(page)
    if page.is_a?(Page)
      (page.custom_route.blank?) ? page_url(page, locale: I18n.locale) : custom_route_url(page.custom_route, locale: I18n.locale)
    else
      (Rails.env.production? || Rails.env.staging?) ? "#{request.protocol}#{request.host}#{url_for(page)}" : "#{request.protocol}#{request.host_with_port}#{url_for(page)}"
    end
  end
  
  # Platform icon. Make sure there are icons for all the different platforms and sizes
  # in the public/images folder
  def platform_icon(software, size=17)
    if software.platform.match(/windows/i)
			image_tag "windows_#{size}.png", style: "vertical-align: middle"
		elsif software.platform.match(/mac/i)
			image_tag "mac_#{size}.png", style: "vertical-align: middle"
		elsif software.platform.match(/linux/i)
			image_tag "tux_#{size}.png", style: "vertical-align: middle"
		end
	end
	
	# Links to software packages for a product that fit a given category
	def software_category_links(product, category="other")
	  links = []
	  product.softwares.each do |software|
	    if software.category == category && software.active?
	      icon = platform_icon(software)
	      link = link_to(software.name, software_path(software, locale: I18n.locale))
	      links << "#{icon} #{link} #{software.version}"
	    end
	  end
	  raw(links.join("<br/>"))
	end

  def seconds_to_HMS(time)
    time = time.to_i
    [time/3600, time/60 % 60, time % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end

  def seconds_to_MS(time)
    time = time.to_i
    [time/60 % 60, time % 60].map{|t| t.to_s.rjust(2,'0')}.join(':')
  end
  
  # Generates links to related products. Pass in any object which has a #products
  # method which returns a collection of Products
  def links_to_related_products(parent)
    begin
      links = []
      parent.products.each do |product|
        links << link_to(product.name, product)
      end
      raw(links.join(", "))
    rescue 
      ""
    end
	end
	
	# Tries to find a ContentTranslation for the provided field for current locale. Falls
	# back to language only or default (english)
	def translate_content(object, method)
	  c = object[method] # (default)
    return c if I18n.locale == I18n.default_locale
	  parent_locale = (I18n.locale.to_s.match(/^(.*)-/)) ? $1 : false
	  translations = ContentTranslation.where(content_type: object.class.to_s, content_id: object.id, content_method: method.to_s)
	  if t = translations.where(locale: I18n.locale).first
	    c = t.content
    elsif parent_locale
      if t = translations.where(locale: parent_locale).first
        c = t.content
      elsif t = translations.where(["locale LIKE ?", "'#{parent_locale}%%'"]).first
        c = t.content
      end
    end
    c.html_safe
	end
	
	def image_url(source)
    abs_path = image_path(source)
    unless abs_path =~ /^http/
      abs_path = "#{request.protocol}#{request.host_with_port}#{abs_path}"
    end
   abs_path
  end
  
  # Render an unordered list of the top top nav
  def supernav
    families = ProductFamily.parents_for_supernav(website, I18n.locale)
    ret = "<ul>"
    families.each do |product_family|
      lastchild = (product_family == families.last) ? "last-child" : ""
      ret += content_tag(:li, link_to(translate_content(product_family, :name), product_family), class: lastchild)
    end
    ret += "</ul>"
    ret.html_safe
  end
  
  # Replacement for render :partial, this version considers the
  # site's brand and checks for a custom partial.
  def render_partial(name, options={})
    if File.exists?(Rails.root.join("app", "views", "#{website.folder}/#{name.gsub(/\/(?!.*\/)/, "/_")}.html.erb"))
      name = "#{website.folder}/#{name}"
    end
    eval("render '#{name}', options")
  end
  	
end
