class AoC
	def initialize(data)
		@data = data
	end

	def one
		@data.each do |x|
			puts "X: #{x}"
		end
	end

	def two

	end
end

def main
	n = ARGV.shift
	runner = AoC.new ARGF.readlines.to_a

	if n == "1"
		runner.one
	else
		runner.two
	end
end
main
