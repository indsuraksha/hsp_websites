require "minitest_helper"

describe SiteMailer do

	before :each do
		DatabaseCleaner.start
		Brand.destroy_all
		@brand = FactoryGirl.create(:brand)
		Brand.any_instance.stubs(:support_email).returns('adam.anderson@harman.com')
	end

  after :each do
    DatabaseCleaner.clean
  end

	describe "contact form" do
		before do
			@contact_message = FactoryGirl.build(:contact_message)
			@mail = SiteMailer.contact_form(@contact_message, @brand)
		end

		it "should have the selected subject" do
			@mail.subject.must_equal @contact_message.subject
		end

		it "should come from the person completing the form" do
			@mail.from.must_equal [@contact_message.email]
		end

		it "should go to the brand's support_email" do
			@mail.to.must_equal ["adam.anderson@harman.com"] # (from the 'setting')
		end

		it "should have the form information" do
			@mail.body.encoded.must_match @contact_message.name
			@mail.body.encoded.must_match @contact_message.email
			@mail.body.encoded.must_match @contact_message.product
			@mail.body.encoded.must_match @contact_message.product_serial_number
			@mail.body.encoded.must_match @contact_message.operating_system
			@mail.body.encoded.must_match @contact_message.shipping_address
			@mail.body.encoded.must_match @contact_message.shipping_country
			@mail.body.encoded.must_match @contact_message.phone
			@mail.body.encoded.must_match @contact_message.message
		end

	end

end