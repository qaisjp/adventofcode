def check(line, x)
	max = line.length
	line[x % max]
end

n = ARGV.shift

class AoC
	@@allowed1 = %w{byr cid ecl eyr hcl hgt iyr pid}
	@@allowed2 = %w{byr ecl eyr hcl hgt iyr pid}
	def initialize(data)
		@data = data.map(&:split)
	end

	def one
		@data.each do |x|
			puts "X: #{x}"
		end
		@data = @data.map do |x|
			x.map do |y|
				y.split(":")[0]
			end
		end
		count = 0
		@data.each do |x|
			x = x.sort
			puts "X: #{x}"
			count += 1 if x == @@allowed1 || x == @@allowed2
		end
		puts count
	end

	def valid?(key, val)
		valid = false
		if key == "byr"
			val = val.to_i
			valid = val >= 1920 && val <= 2002
			puts "byr invalid" unless valid
		elsif key == "iyr"
			val = val.to_i
			valid = val >= 2010 && val <= 2020
			puts "iyr invalid" unless valid
		elsif key == "eyr"
			val = val.to_i
			valid = val >= 2020 && val <= 2030
			puts "eyr invalid" unless valid
		elsif key == "hgt"
			unit = val[-2..-1]
			valid = unit == 'cm' || unit == 'in'
			if valid
				val = val[0..-3].to_i
				if unit == 'cm'
					valid = val >= 150 && val <= 193
				else
					valid = val >= 60 && val <= 76
				end
			end
			puts "hgt invalid" unless valid
		elsif key == "hcl"
			valid = val[0] == "#" && val.length == 7
			if valid
				valid = val[1..-1].split("").all? {|x| (x >= "a" && x <= "f") || (x >= "0" && x <= "9") }
			end
			puts "hcl invalid" unless valid
		elsif key == "ecl"
			valid = %w{amb blu brn gry grn hzl oth}.include? val
			puts "ecl invalid" unless valid
		elsif key == "pid"
			valid = val.length == 9 && (val == "000000000" || val.to_i != 0)
			puts "pid invalid" unless valid
		elsif key == "cid"
			valid = true
		else
			valid = false
			puts "unknown key #{key}"
		end
		valid
	end

	def two
		@data.each do |x|
			puts "X: #{x}"
		end
		valids = []
		@data.map do |x|
			valid = true
			items = x.map do |y|
				next nil unless valid
				key, val = y.split(":")
				valid = valid?(key, val)
				key
			end
			puts "invalid: #{x}\n\n" unless valid
			valids << items if valid
		end
		count = 0

		valids.each do |x|
			x = x.sort
			valid = x == @@allowed1 || x == @@allowed2
			# puts "#{valid}: #{x}"
			count += 1 if valid
		end

		puts count
	end
end
runner = AoC.new ARGF.read.split("\n\n").to_a

raise unless true == runner.valid?("byr", "2002")
raise unless false == runner.valid?("byr", "2003")

raise unless true == runner.valid?("hgt", "60in")
raise unless true == runner.valid?("hgt", "190cm")
raise unless false == runner.valid?("hgt", "190in")
raise unless false == runner.valid?("hgt", "190")

raise unless true == runner.valid?("hcl","#123abc")
raise unless false == runner.valid?("hcl","#123abz")
raise unless false == runner.valid?("hcl", "123abc")

raise unless true == runner.valid?("ecl", "brn")
raise unless false == runner.valid?("ecl", "wat")

raise unless true == runner.valid?("pid", "000000001")
raise unless false == runner.valid?("pid", "0123456789")

if n == "1"
	runner.one
else
	runner.two
end
