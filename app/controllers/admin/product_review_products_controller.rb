class Admin::ProductReviewProductsController < AdminController
  load_and_authorize_resource
  # GET /admin/product_review_products
  # GET /admin/product_review_products.xml
  def index
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render :xml => @product_review_products }
    end
  end

  # GET /admin/product_review_products/1
  # GET /admin/product_review_products/1.xml
  def show
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render :xml => @product_review_product }
    end
  end

  # GET /admin/product_review_products/new
  # GET /admin/product_review_products/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render :xml => @product_review_product }
    end
  end

  # GET /admin/product_review_products/1/edit
  def edit
  end

  # POST /admin/product_review_products
  # POST /admin/product_review_products.xml
  def create
    @called_from = params[:called_from] || 'product'
    respond_to do |format|
      if @product_review_product.save
        format.html { redirect_to([:admin, @product_review_product], :notice => 'ProductReviewProduct was successfully created.') }
        format.xml  { render :xml => @product_review_product, :status => :created, :location => @product_review_product }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product_review_product.errors, :status => :unprocessable_entity }
        format.js
      end
    end
  end

  # PUT /admin/product_review_products/1
  # PUT /admin/product_review_products/1.xml
  def update
    respond_to do |format|
      if @product_review_product.update_attributes(params[:product_review_product])
        format.html { redirect_to([:admin, @product_review_product], :notice => 'ProductReviewProduct was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product_review_product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/product_review_products/1
  # DELETE /admin/product_review_products/1.xml
  def destroy
    @product_review_product.destroy
    respond_to do |format|
      format.html { redirect_to(admin_product_review_products_url) }
      format.xml  { head :ok }
      format.js
    end
  end
end
