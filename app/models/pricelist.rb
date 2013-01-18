class Pricelist 

  def initialize(brand, options = {})
    @brand    = brand
    default_options = {
      subtitle:      "US Dealer", 
      pricing_types: brand.pricing_types, 
      website:       brand.default_website,
      locale:        I18n.default_locale
    }
    @options  = default_options.merge options
    @column_widths = [14, 40, 12, 12]
    @workbook = Spreadsheet::Workbook.new
    @sheet = @workbook.create_worksheet name: "#{@brand.name} #{@options[:subtitle]} Pricelist"
    setup_template 
    fill_content
  end

  def to_s
  	io = StringIO.new
    @workbook.write(io)
    io.string
  end

  def setup_template 
  	fill_page_title_rows
  	fill_column_headers
    set_widths(@sheet, @column_widths)
  end

  def fill_content
    @row_index = 5
    ProductFamily.parents_with_current_products(@options[:website], @options[:locale]).each do |product_family|
	  insert_spacer_row()
      fill_product_family_row(product_family)

      product_family.current_products_plus_child_products(@options[:website]).each do |product|
        if !(product.discontinued?) && product.show_on_website?(@options[:website]) && product.can_be_registered?
          fill_product_row(product)
        end
      end
      @row_index += 1
    end
  end

  def set_widths(sheet, column_widths=[])
  	column_widths.each_with_index { |w,i| sheet.column(i).width = w }
  end

  def fill_page_title_rows
  	subheader   = Spreadsheet::Format.new(weight: :bold, size: 16)
    subheader_r = Spreadsheet::Format.new(weight: :bold, size: 16, horizontal_align: :right)
    
    row = @sheet.row(1)
    row.height = 20
    row.default_format = subheader
    row.push @brand.name, "", "", "", @options[:subtitle]
    row.set_format(4, subheader_r)

    row = @sheet.row(2)
    row.height = 20
    row.default_format = subheader
    row.insert 4, "Confidential Pricelist"
    row.set_format(4, subheader_r)
  end

  def fill_column_headers
    header = @sheet.row(4)
    header.height = 15
	header.default_format = Spreadsheet::Format.new(weight: :bold, size: 10, horizontal_align: :center)
    header.push "Effective #{I18n.l Date.today, format: :long}", "", "MSRP (US$)", "MAP (US$)"
    header.set_format(0, Spreadsheet::Format.new(weight: :bold, size: 10, horizontal_align: :left))

    @options[:pricing_types].each do |pricing_type|
      unless pricing_type.pricelist_order.to_i <= 0
        header.push "#{pricing_type.name} (US$)"
        @column_widths << 12
      end
    end
  end

  def insert_spacer_row
  	row = @sheet.row(@row_index)
  	@spacer_format ||= Spreadsheet::Format.new top: :thick
  	row.default_format = @spacer_format
    5.times { row.push "" }
    @row_index += 1
  end

  def fill_product_family_row(product_family)
  	row = @sheet.row(@row_index)
  	@subheader_format ||= Spreadsheet::Format.new weight: :bold, size: 15
    row.height = 18
    row.default_format = @subheader_format
    row.push << product_family.name
    @row_index += 1
  end

  def fill_product_row(product)
  	row = @sheet.row(@row_index)
	row.push (product.sap_sku.present?) ? product.sap_sku : product.name 
	row.push product.short_description
	row.push product.msrp
	row.push product.street_price
	@options[:pricing_types].each do |pricing_type|
	  unless pricing_type.pricelist_order.to_i <= 0
	    pr = product.price_for(pricing_type).to_f
	    row.push (pr.to_f > 0.0) ? pr : ""
	  end
	end
	@row_index += 1
  end

end