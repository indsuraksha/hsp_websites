class Toolkit::ProductsController < ToolkitController
	before_filter :load_brand
	layout "toolkit"

	def index
	end

	def show
		@product = Product.find(params[:id])
		@images = @product.images_for("toolkit").select{|pa| pa if pa.is_photo?}
	end
end
