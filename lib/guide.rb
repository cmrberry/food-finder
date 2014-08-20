require 'restaurant'
require 'support/number_helper'
require 'support/string_extend'

class Guide
	include NumberHelper

	class Config
		@@actions = ['list','find','add','delete','quit']
		def self.actions; @@actions; end
	end


	def initialize(path=nil)
		# locate the restaurant rext file at the path
		Restaurant.filepath = path
		if Restaurant.file_usable?
		# or create a new file
		elsif Restaurant.create_file
			puts "Created restautant file."
		# exit if create fails
		else 
			puts "Exiting. \n\n"
			exit!
		end
	end

	def launch!
		introduction
		# action loop
		result = nil
		until result == :quit
			action, args = get_action
			result = do_action(action, args)
		end
		conclusion
	end

	def introduction
		puts "\n\n<<< Welcome to the Food Finder >>>\n\n"
		puts "This is an interactive guide to help you find the foods you crave.\n\n"
	end

	def get_action
		action = nil
		# Keep asking user until valid action
		until Guide::Config.actions.include?(action)
			puts "Actions: " + Guide::Config.actions.join(", ") if action
			print "> "
			user_response = gets.chomp
			args = user_response.downcase.strip.split(' ')
			action = args.shift
		end
		return action, args
	end

	def do_action(action, args=[])
		# Take valid action from get_action and execute it
		case action
		when 'list'
			list(args)
		when 'find'
			keyword = args.shift
			find(keyword)
		when 'add'
			add
		when 'delete'
			delete
		when 'quit'
			return :quit
		else 
			puts "\nI don't understand that command.\n"
		end			
	end

	def list(args=[])
		sort_order = args.shift
		sort_order = args.shift if sort_order == "by"
		sort_order = "name" unless ['name','cuisine','price'].include?(sort_order)

		restaurants = Restaurant.saved_restaurants
		
		if args.include?('desc') # If user wants to sort in descending order
			restaurants.sort! do |r1, r2|
				case sort_order
				when 'name' then r2[0].downcase <=> r1[0].downcase
				when 'cuisine' then r2[1].downcase <=> r1[1].downcase
				when 'price' then r2[2].to_i <=> r1[2].to_i
				end
			end
		else # Otherwise sort in ascending order			
			restaurants.sort! do |r1, r2|
				case sort_order
				when 'name' then r1[0].downcase <=> r2[0].downcase
				when 'cuisine' then r1[1].downcase <=> r2[1].downcase
				when 'price' then r1[2].to_i <=> r2[2].to_i
				end
			end
		end
		output_action_header("Listing Restaurants:")
		output_restaurant_table(restaurants)
		puts "You can sort! Try something like 'list cuisine' or 'list by name' or 'list by price desc'"
	end

	def find(keyword="")
		output_action_header("Find a restaurant:")
		if keyword
			restaurants=Restaurant.saved_restaurants
			found = restaurants.select do |rest|
				rest[0].downcase.include?(keyword.downcase) ||
				rest[1].downcase.include?(keyword.downcase) ||
				rest[2].to_i <= keyword.to_i
			end
			output_restaurant_table(found)
		else
			puts "Find a restaurant by searching for a key phrase."
			puts "Examples: 'find pizza' or 'find Mexican' or 'find mex'\n\n"
		end
	end

	def add
		output_action_header("Add a restaurant:")
		restaurant = Restaurant.build_from_questions
		if restaurant.save
			puts "\nRestaurant Added\n\n"
		else
			puts "\nSave Error: Restaurant not added.\n\n"
		end
	end

	def delete
		output_action_header("Delete a restaurant:")
		puts "What is the exact name of the restaurant you want to delete?\n"
		restaurant = gets.chomp.strip.downcase
		if Restaurant.delete(restaurant)
			puts "\nRestaurant Deleted\n\n"
		else
			puts "\nDelete Error: Make sure the name is spelled correctly."
			puts "Try typing 'list' to see the restaurants currently stored.\n\n"
		end
	end

	def conclusion
		puts "\n<<< Goodbye and Bon Appetit! >>>\n\n\n"
	end

	private

	def output_action_header(text)
		puts "\n#{text.upcase.center(60)}\n\n"
	end

	def output_restaurant_table(restaurants=[])
		print " " + "Name".ljust(30)
		print " " + "Cuisine".ljust(20)
		print " " + "Price".rjust(6) + "\n"
		puts "=" * 60
		restaurants.each do |rest|
			line = " " << rest[0].titleize.ljust(30)
			line << " " + rest[1].titleize.ljust(20)
			line << " " + number_to_currency(rest[2].chomp).rjust(6)
			puts line
		end
		puts "No listings found" if restaurants.empty?
		puts "=" * 60
	end


end