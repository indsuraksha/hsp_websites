class Admin::PromotionsController < AdminController
  before_filter :initialize_promotion, only: :create
  load_and_authorize_resource
  
  # GET /admin/promotions
  # GET /admin/promotions.xml
  def index
    @search = @promotions.where(brand_id: website.brand_id).order("start_on DESC").ransack(params[:q])
    if params[:q]
      @promotions = @search.result.order(:name)
    else
      @promotions = @promotions.where(brand_id: website.brand_id).order("start_on DESC")
    end
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render xml: @promotions }
    end
  end

  # GET /admin/promotions/1
  # GET /admin/promotions/1.xml
  def show
    @product_promotion = ProductPromotion.new(promotion: @promotion)
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render xml: @promotion }
    end
  end

  # GET /admin/promotions/new
  # GET /admin/promotions/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render xml: @promotion }
    end
  end

  # GET /admin/promotions/1/edit
  def edit
  end

  # POST /admin/promotions
  # POST /admin/promotions.xml
  def create
    @promotion.brand = website.brand
    respond_to do |format|
      if @promotion.save
        format.html { redirect_to([:admin, @promotion], notice: 'Promotion was successfully created.') }
        format.xml  { render xml: @promotion, status: :created, location: @promotion }
        website.add_log(user: current_user, action: "Created promotion #{@promotion.name}")
      else
        format.html { render action: "new" }
        format.xml  { render xml: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/promotions/1
  # PUT /admin/promotions/1.xml
  def update
    respond_to do |format|
      if @promotion.update_attributes(promotion_params)
        format.html { redirect_to([:admin, @promotion], notice: 'Promotion was successfully updated.') }
        format.xml  { head :ok }
        website.add_log(user: current_user, action: "Updated promotion: #{@promotion.name}")
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/promotions/1
  # DELETE /admin/promotions/1.xml
  def destroy
    @promotion.destroy
    respond_to do |format|
      format.html { redirect_to(admin_promotions_url) }
      format.xml  { head :ok }
    end
    website.add_log(user: current_user, action: "Deleted promotion: #{@promotion.name}")
  end

  private

  def initialize_promotion
    @promotion = Promotion.new(promotion_params)
  end

  def promotion_params
    params.require(:promotion).permit!
  end
end
