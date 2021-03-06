class ProductDocumentsController < ApplicationController
  before_filter :set_locale
  # GET /product_documents
  # GET /product_documents.xml
  def index
    @selected_language = false
    @selected_document_type = false
    if params[:language]
      @selected_language = params[:language]
      if params[:document_type]
        @selected_document_type = params[:document_type]
        @product_documents = []
        ProductDocument.where(language: params[:language], document_type: params[:document_type]).each do |pd|
            @product_documents << pd if pd.product.belongs_to_this_brand?(website) && !pd.product.product_status.is_hidden?
        end
      else
        @document_types = ProductDocument.select("DISTINCT(document_type)")
      end
    else
      @languages = ProductDocument.select("DISTINCT(language)").where("language IS NOT NULL")
    end
    respond_to do |format|
      format.html { render_template } # index.html.erb
      # format.xml  { render xml: ProductDocument.all }
    end
  end

  # GET /product_documents/1
  # GET /product_documents/1.xml
  def show
    @product_document = ProductDocument.find(params[:id])
    if @product_document.product.belongs_to_this_brand?(website) && !@product_document.product.product_status.is_hidden? 
      redirect_to @product_document.document.path, status: :moved_permanently
    else
      redirect_to root_path and return
    end
  end
end
