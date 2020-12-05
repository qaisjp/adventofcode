class AoC
	def initialize(data)
		@data = data
	end

	def bsp(str, lc, rc, lo, hi, last=nil)
		if str == ""
			if last == lc
				return lo
			else
				return hi
			end
		end

		c = str[0]
		if c != lc && c != rc
			puts "unk #{c}"
			raise
		end
		incr = (hi-lo) / 2
		if c == lc
			hi = hi - incr - 1
		else
			lo = lo + incr + 1
		end

		puts "found #{c} - lo: #{lo}, hi: #{hi}\n"

		return bsp(str[1..-1], lc, rc, lo, hi, last=c)
	end

	def parse_line(line)
		first = line[0..6]
		second = line[-3..-1]
		row = bsp(first, "F", "B", 0, 127)
		column = bsp(second, "L", "R", 0, 7)
		[row, column, row*8 + column]
	end

	def one
		print("it is ", @data.map do |x|
			row, col, val = parse_line(x)
			puts "#{x} -- row: #{row}, col: #{col}, val: #{val}\n\n"
			val
		end.max, "\n")
	end

	def two
		require 'set'
		grid = {}
		@data.map do |x|
			row, col, val = parse_line(x)
			# puts "#{x} -- row: #{row}, col: #{col}, val: #{val}\n\n"
			grid[row] ||= {}
			grid[row][col] = true
		end

		(0..127).each do |y|
			val = grid.fetch(y, {})
			vals = (0..7).map {|k| val.fetch(k, false) ? "X" : " "}
			y = "%3.3d" % y
			puts "#{y}: #{vals.join("")}"
		end
	end
end

def main
	n = ARGV.shift
	runner = AoC.new ARGF.readlines(chomp: true).to_a
	raise unless 5 == runner.bsp("RLR", "L", "R", 0, 7)
	puts
	raise unless 44 == runner.bsp("FBFBBFF", "F", "B", 0, 127)
	puts
	puts runner.parse_line("FBFBBFFRLR").join(", ")
	puts
	puts

	if n == "1"
		runner.one
	else
		runner.two
	end
end
main
