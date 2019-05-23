class HideShipping
	def initialize(shipping_rates,cart) 
		@shipping_rates = shipping_rates
		@cart = cart
		@found_no_us_ship = false
		@country = @cart&.shipping_address&.country_code
		@customer_not_canada = @country&.upcase != "CA" ? true : false
	end

	def run()
		if @customer_not_canada
		  @cart.line_items.each do |line_item|
		    product = line_item.variant.product
		    puts "#{product.tags}"
		    if product.tags.include? '__no-us-ship'
		      puts "#{line_item.variant.title} test no shipping to us"
		      @found_no_us_ship = true
		      @shipping_rates.delete_if {| ship_rate | @found_no_us_ship == true}
		      break
		    end
		  end
		end
	end
end

class AccountHideShipping
	def initialize(shipping_rates,cart,tag)
		@shipping_rates = shipping_rates
		@cart = cart
		@accountTag = tag
		@found_hidden_product = false
		@visibleTag = "__" + tag + "_visible"
	end

	def run()
		if @cart.customer&.tags&.any? {|tag| tag.downcase.include?(@accountTag)}
			return
		else
			@cart.line_items.each do |line_item|
				product = line_item.variant.product
				if product&.tags&.include? @visibleTag
					@found_hidden_product = true
		      		@shipping_rates.delete_if {| ship_rate | @found_hidden_product == true}
				end
			end
		end
	end
end

CAMPAIGNS = [HideShipping.new(Input.shipping_rates,Input.cart),
AccountHideShipping.new(Input.shipping_rates,Input.cart,'rcmp'),
AccountHideShipping.new(Input.shipping_rates,Input.cart,'ems')]

CAMPAIGNS.each do |campaign|
  campaign.run()
end

Output.shipping_rates = Input.shipping_rates