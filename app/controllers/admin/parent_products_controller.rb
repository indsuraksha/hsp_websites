class Admin::ParentProductsController < AdminController
  before_filter :initialize_parent_product, only: :create
  load_and_authorize_resource
  
  # GET /admin/parent_products
  # GET /admin/parent_products.xml
  def index
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render xml: @parent_products }
    end
  end

  # GET /admin/parent_products/1
  # GET /admin/parent_products/1.xml
  def show
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render xml: @parent_product }
    end
  end

  # GET /admin/parent_products/new
  # GET /admin/parent_products/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render xml: @parent_product }
    end
  end

  # GET /admin/parent_products/1/edit
  def edit
  end

  # POST /admin/parent_products
  # POST /admin/parent_products.xml
  def create
    @called_from = params[:called_from] || "product"
    respond_to do |format|
      if @parent_product.save
        format.html { redirect_to([:admin, @parent_product], notice: 'Product relationship was successfully created.') }
        format.xml  { render xml: @parent_product, status: :created, location: @parent_product }
        format.js 
        website.add_log(user: current_user, action: "Created parent product: #{@parent_product.parent_product.name}, child: #{@parent_product.product.name}")
      else
        format.html { render action: "new" }
        format.xml  { render xml: @parent_product.errors, status: :unprocessable_entity }
        format.js { render template: 'create_error' }
      end
    end
  end

  # PUT /admin/parent_products/1
  # PUT /admin/parent_products/1.xml
  def update
    respond_to do |format|
      if @parent_product.update_attributes(parent_product_params)
        format.html { redirect_to([:admin, @parent_product], notice: 'Product relationship was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @parent_product.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /admin/parent_products/update_order
  def update_order
    update_list_order(ParentProduct, params["parent_product"])
    render nothing: true
    website.add_log(user: current_user, action: "Sorted parent products list")
  end
  

  # DELETE /admin/parent_products/1
  # DELETE /admin/parent_products/1.xml
  def destroy
    @parent_product.destroy
    respond_to do |format|
      format.html { redirect_to(admin_parent_products_url) }
      format.xml  { head :ok }
      format.js
    end
    website.add_log(user: current_user, action: "Deleted parent product relationship #{@parent_product.product.name}")
  end

  private

  def initialize_parent_product
    @parent_product = ParentProduct.new(parent_product_params)
  end

  def parent_product_params
    params.require(:parent_product).permit!
  end
end
