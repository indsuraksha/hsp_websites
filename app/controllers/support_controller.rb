class SupportController < ApplicationController
  before_filter :set_locale
  # Support home page
  def index
    @contact_message = ContactMessage.new
    @contact_message.require_country = true if require_country?
    if params[:product_id]
      if product = Product.find(params[:product_id])
        if url_matches?("lexicon") && !product.discontinued?
          redirect_to product_path(product, tab: "downloads_and_docs"), status: :moved_permanently and return
        else
          redirect_to product, status: :moved_permanently and return
        end
      end
    end
    render_template
  end

  # Routes to /:locale/training
  def training
    @page_title = "#{website.brand.name} Training"
    @product_training_modules = website.training_modules(module_type: 'product')
    @software_training_modules = website.training_modules(module_type: 'software')
    render_template
  end

  # Warranty registration form
  def warranty_registration
    if request.post?
      @warranty_registration = WarrantyRegistration.new(warranty_registration_params)
      @warranty_registration.brand_id = website.brand_id
      if @warranty_registration.save
        redirect_to support_path, alert: t('blurbs.warranty_registration_success')
      end
    else
      @warranty_registration = WarrantyRegistration.new(subscribe: true, purchased_on: Date.yesterday)
      @warranty_registration.country = "United States" if params[:locale] =~ /\-US$/
      begin
        @warranty_registration.product = Product.find(params[:product_id]) if params[:product_id]
      rescue
        # problem auto-determining the product from the referring link, no big deal
      end
      render_template
    end
  end

  # The site's contact form
  def contact
    @contact_message = ContactMessage.new
    @contact_message.require_country = true if require_country?
    if request.post?
      @contact_message = ContactMessage.new(contact_message_params)
      @contact_message.require_country = true if require_country?
      if verify_recaptcha && @contact_message.valid?
        @contact_message.save
        redirect_to support_path, notice: t('blurbs.contact_form_thankyou')
        SiteMailer.delay.contact_form(@contact_message, website)
      else
        @discontinued_products = Product.discontinued(website)
        render_template(action: "index")
      end
    else
      @discontinued_products = Product.discontinued(website)
      render_template(action: "index")
    end
  end
  
  # Parts request form
  def parts
    @page_title = t('titles.part_request')
    unless website.has_parts_form?
      redirect_to support_path and return false
    end
    @contact_message = ContactMessage.new(message_type: "part_request")
    if request.post?
      @contact_message = ContactMessage.new(contact_message_params)
      @contact_message.message_type = "part_request"
      if @contact_message.valid?
        @contact_message.save
        redirect_to support_path, notice: t('blurbs.parts_request_thankyou')
        SiteMailer.delay.contact_form(@contact_message, website)
      end
    else
      render_template
    end
  end
  
  # RMA request form
  def rma
    @page_title = t('titles.rma_request')
    unless website.has_rma_form?
      redirect_to support_path and return false
    end
    @contact_message = ContactMessage.new(message_type: "rma_request")
    if request.post?
      @contact_message = ContactMessage.new(contact_message_params)
      @contact_message.message_type = "rma_request"
      if @contact_message.valid?
        @contact_message.save
        redirect_to support_path, notice: t('blurbs.rma_request_thankyou')
        SiteMailer.delay.contact_form(@contact_message, website)
      end
    else
      render_template
    end
  end
  
  def warranty_policy
    @page_title = "Warranty Policy"
    products = Product.all_for_website(website) - Product.non_supported(website)
    @products = products.select{|p| p if p.warranty_period.to_i > 0}
    render_template
  end

  # Simple list of RoHS compliant products
  def rohs
    @products = website.current_products.select{|p| p if p.rohs}
    render_template
  end
  
  # Iframe page for info that comes from Salesforce
  def troubleshooting
    @src = website.value_for("troubleshooting_url")
    render_template
  end
  
  # Service center lookup by zipcode
  def service_lookup
    @page_title = t('titles.service_centers')
    @err = ""
    @results = []
    if params[:zip]
      session[:zip] = params[:zip]
      @page_title += " " + t('near_zipcode', zip: params[:zip])
      begin
        @results = []
        count = 0
        zip = (params[:zip].to_s.match(/^\d*$/)) ? "zipcode #{params[:zip]}" : params[:zip]
        origin = Geokit::Geocoders::MultiGeocoder.geocode(zip)
        brand = Brand.find(website.service_centers_from_brand_id || website.brand_id)
        brand.service_centers.near(origin: origin, within: 100).order("distance ASC").each do |d|
          unless count > 10 || d.exclude?
            @results << d
            count += 1
          end
        end
        # ServiceCenter.find(:all, conditions: ["brand_id = ?", brand_id], origin: params[:zip], order: 'distance', within: 100, limit: 10).each do |d|
        #   @results << d #unless d.exclude?
        # end
        unless count > 0
          @err = t('errors.no_service_centers_found', zip: params[:zip])
        end
      rescue
        redirect_to(support_path, alert: t('errors.geocoding')) and return false
      end
    end
    render_template
  end

  # Vintage repair facilities
  def vintage_repair
    @page_title = "Vintage Repair"
    @results = ServiceCenter.where(brand_id: website.brand_id, vintage: true)
  end

  # All repair facilities
  def all_repair
    @page_title = "All Repair Facilities"
    @results = ServiceCenter.where(brand_id: website.brand_id).order("UPPER(name)")
  end
  
  # Power Supplies page. Really, this could be used to build a similar page for
  # any Specification
  def power_supplies
    @specification = Specification.where(name: "Power Supply").first
    render_template
  end
  
  # Downloads page
  def downloads
    downloads = website.all_downloads
    @downloads = downloads.keys.sort{|a,b| a.to_s.downcase <=> b.to_s.downcase}.collect{|k| downloads[k]}
    render_template
  end
  
  def zipped_downloads
    render text: "Dynamic zips are no longer available."
    # temp_file = website.zip_downloads(params[:download_type])
    # send_file temp_file.path, type: 'application/zip', disposition: 'attachment', filename: "#{params[:download_type]}.zip"
    # temp_file.close
  end

  # For dbx, a quick list of CAD files
  def cad
    @page_title = "CAD Files"
    render_template
  end

  # Also for dbx, a list of speaker tunings
  def speaker_tunings
    @page_title = "Speaker Tunings"
    render_template
  end
  
  private
  
  # Validate captcha data from params[:yoyo] (question_key) and params[:ans] (answer#)
  def validate_captcha
    Captcha.correct?(session[:yoyo], params[:ans])
  end

  def require_country?
    url_matches?("lexicon") || url_matches?("digitech") || url_matches?("hardwire") || url_matches?("vocalist")
  end

  def url_matches?(name)
    !!(website.brand.name.match(/#{name}/i))
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def warranty_registration_params
    params.require(:warranty_registration).permit(:title, :first_name, :last_name, :middle_initial, :company, :jobtitle, :address1, :city, :state, :zip, :country, :phone, :fax, :email, :subscribe, :product_id, :serial_number, :registered_on, :purchased_on, :purchased_from, :purchase_country, :purchase_price, :age, :marketing_question1, :marketing_question2, :marketing_question3, :marketing_question4, :marketing_question5, :marketing_question6, :marketing_question7, :comments)
  end

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :subject, :message, :created_at, :updated_at, :product, :operating_system, :company, :account_number, :phone, :fax, :billing_address, :billing_city, :billing_state, :billing_zip, :shipping_address, :shipping_city, :shipping_state, :shipping_zip, :product_sku, :product_serial_number, :warranty, :purchased_on, :part_number, :board_location, :shipping_country)
  end
  
end
