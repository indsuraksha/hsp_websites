class Admin::ProductSoftwaresController < AdminController
  before_filter :initialize_product_software, only: :create
  load_and_authorize_resource
  
  # GET /admin/product_softwares
  # GET /admin/product_softwares.xml
  def index
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render xml: @product_softwares }
    end
  end

  # GET /admin/product_softwares/1
  # GET /admin/product_softwares/1.xml
  def show
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render xml: @product_software }
    end
  end

  # GET /admin/product_softwares/new
  # GET /admin/product_softwares/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render xml: @product_software }
    end
  end

  # GET /admin/product_softwares/1/edit
  def edit
  end

  # POST /admin/product_softwares
  # POST /admin/product_softwares.xml
  def create
    @called_from = params[:called_from] || 'product'
    respond_to do |format|
      if @product_software.save
        format.html { redirect_to([:admin, @product_software], notice: 'Product Software was successfully created.') }
        format.xml  { render xml: @product_software, status: :created, location: @product_software }
        format.js
        website.add_log(user: current_user, action: "Added #{@product_software.software.name} to #{@product_software.product.name}")
      else
        format.html { render action: "new" }
        format.xml  { render xml: @product_software.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /admin/product_softwares/1
  # PUT /admin/product_softwares/1.xml
  def update
    respond_to do |format|
      if @product_software.update_attributes(product_software_params)
        format.html { redirect_to([:admin, @product_software], notice: 'Product Software was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @product_software.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /admin/product_softwares/update_order
  def update_order
    params["product_software"].to_a.each_with_index do |item, pos|
      if params[:called_from] == "software"
        ProductSoftware.update(item, product_position: (pos + 1))
      else
        ProductSoftware.update(item, software_position: (pos + 1))
      end
    end
    render nothing: true
    website.add_log(user: current_user, action: "Sorted product software")
  end

  # DELETE /admin/product_softwares/1
  # DELETE /admin/product_softwares/1.xml
  def destroy
    @product_software.destroy
    respond_to do |format|
      format.html { redirect_to(admin_product_softwares_url) }
      format.xml  { head :ok }
      format.js
    end
    website.add_log(user: current_user, action: "Removed #{@product_software.software.name} from #{@product_software.product.name}")
  end

  private

  def initialize_product_software
    @product_software = ProductSoftware.new(product_software_params)
  end

  def product_software_params
    params.require(:product_software).permit!
  end
end
