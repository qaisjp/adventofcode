require 'set'

class AoC
	def initialize(data)
		@groups = data.map(&:split)
	end

	def one
		count = @groups.sum do |group|
			group.each_with_object(Set.new) do |person, set|
				set.merge person.split("")
			end.size
		end
		puts "Total count: #{count}"
	end

	def two
		count = @groups.sum do |group|
			set = nil
			group.each do |person|
				chars = person.split("").to_set
				set ||= chars
				set = set.intersection chars
			end
			set.size
		end
		puts "Total count: #{count}"
	end
end

def main
	n = ARGV.shift
	runner = AoC.new ARGF.read.split("\n\n").to_a

	if n == "1"
		runner.one
	else
		runner.two
	end
end
main
