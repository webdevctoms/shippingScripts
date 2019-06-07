class TiedItemsShipping
	def initialize(shipping_rates,cart)
		@shipping_rates = shipping_rates
		@cart = cart
		@productIds = {}
		@productMissing = false
	end

	def captureIds
		@cart.line_items.each do |line_item|
			productId = line_item.variant.product.id.to_s
			@productIds[productId] = productId
		end
	end

	def run()
		captureIds()
		@cart.line_items.each do |line_item|
			product = line_item.variant.product
			if product&.tags.length > 0
				currentProductTags = product&.tags
				currentProductTags.each do |tag|
					if tag.include?("dependent")
						trimmedTag = tag.split("__")[1]		
						dependentId = trimmedTag.split("_")[1]
						if @productIds[dependentId]
							
						else
							@productMissing = true
						    @shipping_rates.delete_if {| ship_rate | @productMissing == true}
						end
					end
				end	
			end
		end
	end
end

CAMPAIGNS = [TiedItemsShipping.new(Input.shipping_rates,Input.cart)]

CAMPAIGNS.each do |campaign|
  campaign.run()
end

Output.shipping_rates = Input.shipping_rates