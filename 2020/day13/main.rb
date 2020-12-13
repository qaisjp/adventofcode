# frozen_string_literal: true

require 'sorbet-runtime'

# AoC
class AoC
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @earliest_depart = T.let(data[0].to_i, Integer)
    @bus_ids = data[1].split(",")
  end

  def one
    ids = @bus_ids.filter {|x| x != "x"}.map(&:to_i)
    puts "#{ids}"

    earliest = nil

    # move forward to find an id that is perfectly divisible
    current_time = @earliest_depart
    while earliest.nil?
      current_time += 1
      ids.each do |id|
        test = current_time.to_f/id
        if test.to_i == test
          earliest = id
          break
        end
      end

      if current_time == 0
        raise "current_time is 0"
      end
    end

    wait_time = current_time - @earliest_depart

    puts "bus #{earliest} departs at #{current_time}"
    puts "mins to wait: #{wait_time}"
    earliest * wait_time
  end

  def two
    int_ids = @bus_ids.filter {|x| x != "x"}.map(&:to_i)
    ids = @bus_ids.map do |x|
      if x == "x"
        x
      else
        x.to_i
      end
    end

    most_frequent_id = T.let(int_ids.min, Integer)
    puts "Most frequent: #{most_frequent_id}"
    initial_time = 0
    if @earliest_depart > 1000
      initial_time = 100000000000000
    end

    loop do
      initial_time += 1

      passed = true
      ids.each_with_index do |id, offset|
        next if id == "x"

        test = (initial_time + offset).to_f/id
        if test.to_i != test
          passed = false
          break
        end
      end

      break if passed
    end

    initial_time
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    raise unless 1068781 == AoC.new(["1", "7,13,x,x,59,x,31,19"]).two
    raise unless 3417 == AoC.new(["1", "17,x,13,19"]).two
    raise unless 754018 == AoC.new(["1", "67,7,59,61"]).two
    raise unless 779210 == AoC.new(["1", "67,x,7,59,61"]).two
    raise unless 1261476 == AoC.new(["1", "67,7,x,59,61"]).two
    raise unless 1202161486 == AoC.new(["1", "1789,37,47,1889"]).two

    puts "Running main"
    puts "Result: #{runner.two}"
  end
end
main
