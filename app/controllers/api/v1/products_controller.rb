module Api
  module V1
    class ProductsController < ApplicationController
      before_filter :restrict_api_access
      respond_to :json
      
      def index
        @products = Product.all
        respond_with @products
      end
      
      def show
        @product = Product.find(params[:id])
        respond_with @product
      end
      
      # def create
      #   @product = Product.create(params[:product])
      #   respond_with @product
      # end
      
      # def update
      #   @product = Product.update(params[:id], params[:products])
      #   respond_with @product
      # end
      
      # def destroy
      #   @product = Product.destroy(params[:id])
      #   respond_with @product
      # end

    end
  end
end

