# Open Ruby core String class to add method
class String
	# write method to capitalize the first letter of every word
	def titleize
		self.split(' ').collect{|word| word.capitalize}.join(' ')
	end

end
