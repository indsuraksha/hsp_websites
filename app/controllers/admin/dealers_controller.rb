class Admin::DealersController < AdminController
  before_filter :initialize_dealer, only: :create
  load_and_authorize_resource
  # GET /admin/dealers
  # GET /admin/dealers.xml
  def index
    @this_brand = !!(params[:this_brand].to_i > 0)
    @search = (@this_brand) ? website.brand.dealers.ransack(params[:q]) : Dealer.ransack(params[:q])
    if params[:q]
      @dealers = @search.result
    else
      @dealers = []
    end
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render xml: @dealers }
    end
  end

  # GET /admin/dealers/1
  # GET /admin/dealers/1.xml
  def show
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render xml: @dealer }
    end
  end

  # GET /admin/dealers/new
  # GET /admin/dealers/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render xml: @dealer }
    end
  end

  # GET /admin/dealers/1/edit
  def edit
  end

  # POST /admin/dealers
  # POST /admin/dealers.xml
  def create
    @dealer.skip_sync_from_sap = true
    respond_to do |format|
      if @dealer.save
        BrandDealer.create(brand_id: website.brand_id, dealer_id: @dealer.id)
        format.html { redirect_to([:admin, @dealer], notice: 'Dealer was successfully created.') }
        format.xml  { render xml: @dealer, status: :created, location: @dealer }
        website.add_log(user: current_user, action: "Created dealer #{@dealer.name}")
      else
        format.html { render action: "new" }
        format.xml  { render xml: @dealer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/dealers/1
  # PUT /admin/dealers/1.xml
  def update
    @dealer.skip_sync_from_sap = true
    respond_to do |format|
      if @dealer.update_attributes(dealer_params)
        format.html { redirect_to([:admin, @dealer], notice: 'Dealer was successfully updated.') }
        format.xml  { head :ok }
        format.js
        website.add_log(user: current_user, action: "Updated dealer #{@dealer.name}")
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @dealer.errors, status: :unprocessable_entity }
        format.js {}
      end
    end
  end

  # DELETE /admin/dealers/1
  # DELETE /admin/dealers/1.xml
  def destroy
    @dealer.destroy
    respond_to do |format|
      format.html { redirect_to(admin_dealers_url) }
      format.xml  { head :ok }
    end
    website.add_log(user: current_user, action: "Deleted dealer #{@dealer.name}")
  end

  private

  def initialize_dealer
    @dealer = Dealer.new(dealer_params)
  end

  def dealer_params
    params.require(:dealer).permit!
  end
end
