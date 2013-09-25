require "test_helper"

describe "Marketing Projects Integration Test" do

	before :each do
    DatabaseCleaner.start
    Brand.destroy_all
    setup_toolkit_brands
    @host = HarmanSignalProcessingWebsite::Application.config.queue_url 
    host! @host
    Capybara.default_host = "http://#{@host}" 
    Capybara.app_host = "http://#{@host}" 
  end

  after :each do
    DatabaseCleaner.clean
  end

  #
  # Market managers
  #
  describe "Market manager actions" do 
    before do
      @project_type = FactoryGirl.create(:marketing_project_type)
      setup_and_login_market_manager
      visit new_marketing_queue_marketing_project_url(host: @host)
    end

    describe "New project" do
      it "should link to the new project form" do 
        must_have_content "New Project"
        current_path.must_equal new_marketing_queue_marketing_project_path
      end

      it "should require the project name" do
        select @digitech.name, from: "marketing_project_brand_id"
        fill_in :marketing_project_due_on, with: 2.weeks.from_now.to_s
        click_on "Create Marketing project"
        must_have_content "can't be blank"
      end

      it "should offer a selection of brands" do
        fill_in :marketing_project_name, with: "Build the death star"
        must_have_select "marketing_project_brand_id"
        select @digitech.name, from: "marketing_project_brand_id"
        click_on "Create Marketing project"
        MarketingProject.last.brand_id.must_equal @digitech.id
      end

      it "should offer a selection of project templates" do 
        fill_in :marketing_project_name, with: "Build the death star"
        fill_in :marketing_project_due_on, with: 2.weeks.from_now.to_s
        select @digitech.name, from: "marketing_project_brand_id"
        select @project_type.name, from: "marketing_project_marketing_project_type_id"
        click_on "Create Marketing project"
        project = MarketingProject.last
        project.marketing_project_type_id.must_equal @project_type.id
        project.due_on.to_date.must_equal 2.weeks.from_now.to_date
      end

      it "should have autogenerated tasks when selecting a template" do 
        @project_type_task = FactoryGirl.create(:marketing_project_type_task, 
          marketing_project_type: @project_type,
          name: "Get plenty of rest",
          due_offset_number: 1,
          due_offset_unit: "weeks")
        fill_in :marketing_project_name, with: "Build the death star"
        fill_in :marketing_project_due_on, with: 4.weeks.from_now.to_s
        select @digitech.name, from: "marketing_project_brand_id"
        select @project_type.name, from: "marketing_project_marketing_project_type_id"
        click_on "Create Marketing project"
        project = MarketingProject.last
        project.marketing_tasks.first.name.must_equal @project_type_task.name 
        project.marketing_tasks.first.due_on.to_date.must_equal 3.weeks.from_now.to_date
      end

      it "should not require a template" do 
        fill_in :marketing_project_name, with: "Build the death star"
        fill_in :marketing_project_due_on, with: 5.weeks.from_now.to_s
        select @digitech.name, from: "marketing_project_brand_id"
        click_on "Create Marketing project"
        project = MarketingProject.last
        project.due_on.to_date.must_equal 5.weeks.from_now.to_date
        current_path.must_equal marketing_queue_marketing_project_path(project)
      end        

    end
  end

  describe "View project" do 
    it "should show tasks to-do"
    it "should show completed tasks"
  end

  describe "Converting a project to a template" do 
    before do
      @project = FactoryGirl.create(:marketing_project, due_on: 30.days.from_now)
      @task1 = FactoryGirl.create(:marketing_task, marketing_project: @project, due_on: 20.days.from_now, name: "Task 1")
      @task2 = FactoryGirl.create(:marketing_task, marketing_project: @project, due_on: 1.month.from_now, name: "Task 2")
      setup_and_login_market_manager
      visit marketing_queue_marketing_project_url(@project, host: @host)
    end

    it "should have a button to convert a project to a template" do 
      click_on "Save as a template"
      fill_in :marketing_project_type_name, with: "Cool new template"
      uncheck :marketing_project_type_marketing_project_type_tasks_attributes_1_keep
      click_on "Create Project Template"
      mpt = MarketingProjectType.last
      mpt.marketing_project_type_tasks.count.must_equal 1
      mptt = mpt.marketing_project_type_tasks.first
      mptt.due_offset_number.must_equal 10
      mptt.due_offset_unit.must_equal "days"
    end
  end

  # describe "Existing project" do 
  #   it "should add tasks from the project page"
  #   it "should show tasks in a gantt style"
  # end

end