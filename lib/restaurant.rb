require 'support/number_helper'
require 'fileutils'
require 'tempfile'

class Restaurant
	include NumberHelper

	@@filepath = nil

	def self.filepath=(path=nil)
		@@filepath = File.join(APP_ROOT,path)
	end

	def self.file_exists?
		# class should know if the restaurant files file exists 
		if @@filepath && File.exists?(@@filepath)
			return true
		else
			return false
		end
	end

	def self.file_usable?
		return false unless @@filepath
		return false unless File.exists?(@@filepath)
		return false unless File.readable?(@@filepath)
		return false unless File.writable?(@@filepath)
		return true
	end

	def self.create_file
		# create the restaurant file
		File.open(@@filepath, 'w') unless file_exists?
		return file_usable?
	end

	def self.saved_restaurants
		# read the restaurant file
		restaurants = []
		if file_usable?
			file = File.new(@@filepath, 'r')
			file.each_line do |line|
				restaurants << line.split("\t")
			end
			file.close
		end
		return restaurants
		# return instances of restaurant
	end

	def self.build_from_questions
		print "Restaurant name: "
		name = gets.chomp.strip

		print "Cuisine type: "
		cuisine = gets.chomp.strip

		price = -1
		until price > 0
			puts "\nPlease enter the average price as a number.\n" if price == 0
			print "Average price: "
			price = gets.chomp.strip.to_i
		end

		return self.new(name, cuisine, price)
	end

	def self.delete(delete_name)
		return false unless Restaurant.file_usable?
		tmp = Tempfile.new("extract")
		lines_deleted = 0
		open(@@filepath, 'r').each do |l| 
			if l.split("\t")[0].downcase != (delete_name)
				tmp << l 
			else 
				lines_deleted += 1
			end
		end
		tmp.close
		FileUtils.mv(tmp.path, @@filepath) unless lines_deleted == 0
		return false unless lines_deleted > 0
		return true
	end


	attr_accessor :name, :cuisine, :price

	def initialize(name="",cuisine="",price="")
		@name = name
		@cuisine = cuisine
		@price = price
	end

	def save
		return false unless Restaurant.file_usable?
		File.open(@@filepath, 'a') do |file|
			file.puts "#{[@name, @cuisine, @price].join("\t")}\n"
		end
		return true
	end

end
