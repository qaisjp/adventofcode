def check(line, x)
	max = line.length
	line[x % max]
end

n = ARGV.shift
$ys = ARGF.each_line(chomp: true).to_a

def incr(xx, yy)
	y = 0
	x = 0
	found = 0
	loop do
		break if y >= $ys.length
		item = check($ys[y], x)
		if item == "#"
			found += 1
		end
		# print(item, found, "\n")
		y += yy
		x += xx
	end
	found
end

def one
	puts incr(3,1)
end

def two
	puts(incr(1, 1) * incr(3,1) * incr(5,1) * incr(7,1) * incr(1,2))
end

if n == "1"
	one
elsif n == "2"
	two
else
	puts "shrug"
end
