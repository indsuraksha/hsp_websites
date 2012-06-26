class Admin::ProductFamiliesController < AdminController
  load_and_authorize_resource
  after_filter :expire_product_families_cache, :except => [:index, :show, :new, :edit]

  # GET /admin/product_families
  # GET /admin/product_families.xml
  def index
    @product_families = ProductFamily.all_parents(website)
    @children = website.product_families.where("parent_id IS NOT NULL").order(:name)
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render :xml => @product_families }
    end
  end

  # GET /admin/product_families/1
  # GET /admin/product_families/1.xml
  def show
    @product_family_product = ProductFamilyProduct.new(:product_family => @product_family)
    @locale_product_family = LocaleProductFamily.new(:product_family => @product_family)
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render :xml => @product_family }
    end
  end

  # GET /admin/product_families/new
  # GET /admin/product_families/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render :xml => @product_family }
    end
  end

  # GET /admin/product_families/1/edit
  def edit
  end

  # POST /admin/product_families
  # POST /admin/product_families.xml
  def create
    @product_family.brand_id ||= website.brand_id
    respond_to do |format|
      if @product_family.save
        format.html { redirect_to([:admin, @product_family], :notice => 'ProductFamily was successfully created.') }
        format.xml  { render :xml => @product_family, :status => :created, :location => @product_family }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product_family.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # PUT /admin/product_families/update_order
  def update_order
    update_list_order(ProductFamily, params["product_family"])
    render :nothing=>true
  end

  # PUT /admin/product_families/1
  # PUT /admin/product_families/1.xml
  def update
    respond_to do |format|
      if @product_family.update_attributes(params[:product_family])
        format.html { redirect_to([:admin, @product_family], :notice => 'ProductFamily was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product_family.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/product_families/1
  # DELETE /admin/product_families/1.xml
  def destroy
    @product_family.destroy
    respond_to do |format|
      format.html { redirect_to(admin_product_families_url) }
      format.xml  { head :ok }
    end
  end

  # Delete custom background
  def delete_background
    @product_family = ProductFamily.find(params[:id])
    @product_family.update_attributes(:background_image => nil)
    respond_to do |format|
      format.html { redirect_to(edit_admin_product_family_path(@product_family), :notice => "Background was deleted.") }
      format.js 
    end
  end
  
end
