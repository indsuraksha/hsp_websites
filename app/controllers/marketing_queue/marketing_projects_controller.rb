class MarketingQueue::MarketingProjectsController < MarketingQueueController
	layout "marketing_queue"
  before_filter :load_brand_if_present
  after_filter :keep_brand_in_session, only: [:show, :edit, :create, :update]
	load_resource

  def index
    @marketing_projects = []
    if @brand
      @marketing_projects = MarketingProject.open.where(brand_id: @brand.id)
    elsif params[:q]
      @q = MarketingProject.ransack(params[:q])
      @marketing_projects = @q.result
      @q2 = MarketingTask.ransack(params[:q])
      @marketing_tasks = @q2.result
    end
    respond_to do |format|
      format.html {
        if @brand
          redirect_to marketing_queue_brand_path(@brand) and return
        elsif @marketing_projects.count == 0 && @marketing_tasks.count == 0
          render text: "No results found.", layout: true and return
        end
      }
      format.xml { render xml: @marketing_projects.order("UPPER(name)") }
      format.json { render json: @marketing_projects.order("UPPER(name)") }
      format.js
    end    
  end

  def show
    @marketing_task = MarketingTask.new(marketing_project_id: @marketing_project.id, brand_id: @marketing_project.brand_id, due_on: @marketing_project.due_on)
    @marketing_attachment = MarketingAttachment.new(marketing_project_id: @marketing_project.id)
    @marketing_comment = MarketingComment.new
  end

	def new
    if params[:marketing_project_type_id]
      @marketing_project.marketing_project_type_id = params[:marketing_project_type_id]
    end
    if @brand
      @marketing_project.brand_id = @brand.id
    elsif session[:brand_id]
      @marketing_project.brand_id = session[:brand_id]
    end
	end

	def create
    @marketing_project.user_id = current_marketing_queue_user.id
    respond_to do |format|
      if @marketing_project.save
        format.html { redirect_to([:marketing_queue, @marketing_project], notice: 'Project was successfully created.') }
        format.xml  { render xml: @marketing_project, status: :created, location: @marketing_project }
      else
        format.html { render action: "new" }
        format.xml  { render xml: @marketing_project.errors, status: :unprocessable_entity }
      end
    end
	end

  def edit    
  end

  def update
    respond_to do |format|
      if @marketing_project.update_attributes(params[:marketing_project])
        format.html { redirect_to([:marketing_queue, @marketing_project], notice: 'Project was successfully updated.') }
        format.xml  { render xml: @marketing_project, status: :created, location: @marketing_project }
      else
        format.html { render action: "edit" }
        format.xml  { render xml: @marketing_project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @marketing_project.destroy
    respond_to do |format|
      format.html { redirect_to([:marketing_queue, @marketing_project.brand], notice: 'The project was deleted.') }
    end
  end

  private

  def load_brand_if_present
    if params[:brand_id]
      @brand = Brand.find params[:brand_id]
      session[:brand_id] = params[:brand_id]
    end
  end

  def keep_brand_in_session
    if @marketing_project.brand
      session[:brand_id] = @marketing_project.brand_id
    end    
  end
end
