class Admin::ProductSpecificationsController < AdminController
  load_and_authorize_resource :except => [:copy, :update_order]
  skip_authorization_check :only => [:copy, :update_order]

  # GET /admin/product_specifications
  # GET /admin/product_specifications.xml
  def index
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render :xml => @product_specifications }
    end
  end

  # GET /admin/product_specifications/1
  # GET /admin/product_specifications/1.xml
  def show
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render :xml => @product_specification }
    end
  end

  # GET /admin/product_specifications/new
  # GET /admin/product_specifications/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render :xml => @product_specification }
    end
  end

  # GET /admin/product_specifications/1/edit
  def edit
  end

  # POST /admin/product_specifications
  # POST /admin/product_specifications.xml
  def create
    begin
      specification = Specification.new(params[:specification])
      if specification.save
        @product_specification.specification = specification
      end
    rescue
      # probably didn't have a form that can provide a new Specification
    end
    respond_to do |format|
      if @product_specification.save
        format.html { redirect_to([:admin, @product_specification.product], :notice => 'Product specification was successfully created.') }
        format.xml  { render :xml => @product_specification, :status => :created, :location => @product_specification }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product_specification.errors, :status => :unprocessable_entity }
        format.js { render :template => "create_error" }
      end
    end
  end

  # PUT /admin/product_specifications/1
  # PUT /admin/product_specifications/1.xml
  def update
    respond_to do |format|
      if @product_specification.update_attributes(params[:product_specification])
        format.html { redirect_to([:admin, @product_specification.product], :notice => 'Product specification was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product_specification.errors, :status => :unprocessable_entity }
      end
    end
  end

  # POST /admin/product_families/update_order
  def update_order
    update_list_order(ProductSpecification, params["product_specification"])
    render :nothing=>true
  end

  # Copies ALL the product specs from one to another product
  def copy
    product = Product.find(params[:id])
    product_specification = ProductSpecification.new(params[:product_specification])
    product_specification.product.product_specifications.each do |ps|
      new_ps = ps.dup
      new_ps.id = nil # seems dumb to have to do this
      new_ps.product_id = product.id
      new_ps.save
    end
    respond_to do |format|
      format.html { redirect_to [:admin, product], :notice => "I've copied what specs I could. Have a look."}
    end
  end

  # DELETE /admin/product_specifications/1
  # DELETE /admin/product_specifications/1.xml
  def destroy
    @product_specification.destroy
    respond_to do |format|
      format.html { redirect_to(admin_product_specifications_url) }
      format.xml  { head :ok }
      format.js
    end
  end
end
