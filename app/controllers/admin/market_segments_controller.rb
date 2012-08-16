class Admin::MarketSegmentsController < AdminController
  load_and_authorize_resource
  # GET /admin/market_segments
  # GET /admin/market_segments.xml
  def index
    @market_segments = @market_segments.where(brand_id: website.brand_id)
    respond_to do |format|
      format.html { render_template } # index.html.erb
      format.xml  { render xml: @market_segments }
    end
  end

  # GET /admin/market_segments/1
  # GET /admin/market_segments/1.xml
  def show
    @market_segment_product_family = MarketSegmentProductFamily.new(market_segment: @market_segment)
    respond_to do |format|
      format.html { render_template } # show.html.erb
      format.xml  { render xml: @market_segment }
    end
  end

  # GET /admin/market_segments/new
  # GET /admin/market_segments/new.xml
  def new
    respond_to do |format|
      format.html { render_template } # new.html.erb
      format.xml  { render xml: @market_segment }
    end
  end

  # GET /admin/market_segments/1/edit
  def edit
  end

  # POST /admin/market_segments
  # POST /admin/market_segments.xml
  def create
    @market_segment.brand = website.brand
    respond_to do |format|
      if @market_segment.save
        format.html { redirect_to([:admin, @market_segment], notice: 'Market Segment was successfully created.') }
        format.xml  { render xml: @market_segment, status: :created, location: @market_segment }
        website.add_log(user: current_user, action: "Created a market segment: #{@market_segment.name}")
      else
        format.html { render action: "new" }
        format.xml  { render xml: @market_segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /admin/market_segments/1
  # PUT /admin/market_segments/1.xml
  def update
    respond_to do |format|
      if @market_segment.update_attributes(params[:market_segment])
        format.html { redirect_to([:admin, @market_segment], notice: 'Market Segment was successfully updated.') }
        format.xml  { head :ok }
        website.add_log(user: current_user, action: "Updated market segment #{@market_segment.name}")
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @market_segment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /admin/market_segments/1
  # DELETE /admin/market_segments/1.xml
  def destroy
    @market_segment.destroy
    respond_to do |format|
      format.html { redirect_to(admin_market_segments_url) }
      format.xml  { head :ok }
    end
    website.add_log(user: current_user, action: "Deleted market segment #{@market_segment.name}")
  end
end
