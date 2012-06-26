class Admin::ArtistProductsController < AdminController
  load_and_authorize_resource
  # GET /artist_products
  # GET /artist_products.xml
  def index
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render :xml => @artist_products }
    end
  end

  # GET /artist_products/1
  # GET /artist_products/1.xml
  def show
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render :xml => @artist_product }
    end
  end

  # GET /artist_products/new
  # GET /artist_products/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render :xml => @artist_product }
    end
  end

  # GET /artist_products/1/edit
  def edit
  end

  # POST /artist_products
  # POST /artist_products.xml
  def create
    @called_from = params[:called_from] || 'product'
    respond_to do |format|
      if @artist_product.save
        format.html { redirect_to([:admin, @artist_product], :notice => 'Artist product was successfully created.') }
        format.xml  { render :xml => @artist_product, :status => :created, :location => @artist_product }
        format.js
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @artist_product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /artist_products/1
  # PUT /artist_products/1.xml
  def update
    respond_to do |format|
      if @artist_product.update_attributes(params[:artist_product])
        format.html { redirect_to([:admin, @artist_product.artist], :notice => 'Artist product was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @artist_product.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /artist_products/1
  # DELETE /artist_products/1.xml
  def destroy
    @artist_product.destroy
    respond_to do |format|
      format.html { redirect_to([:admin, @artist_product.artist]) }
      format.xml  { head :ok }
      format.js
    end
  end
end
