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

  ### FROM ROSETTA CODE
  def extended_gcd(a, b)
    last_remainder, remainder = a.abs, b.abs
    x, last_x, y, last_y = 0, 1, 1, 0
    while remainder != 0
      last_remainder, (quotient, remainder) = remainder, last_remainder.divmod(remainder)
      x, last_x = last_x - quotient*x, x
      y, last_y = last_y - quotient*y, y
    end
    return last_remainder, last_x * (a < 0 ? -1 : 1)
  end

  def invmod(e, et)
    g, x = extended_gcd(e, et)
    if g != 1
      raise 'Multiplicative inverse modulo does not exist!'
    end
    x % et
  end

  def chinese_remainder(mods, remainders)
    max = mods.inject( :* )  # product of all moduli
    series = remainders.zip(mods).map{ |r,m| (r * max * invmod(max/m, m) / m) }
    series.inject( :+ ) % max
  end
  ### END ROSETTA CODE

  def two
    int_ids = @bus_ids.filter {|x| x != "x"}.map(&:to_i)
    ids = @bus_ids.map do |x|
      if x == "x"
        x
      else
        x.to_i
      end
    end

    chinese_remainder(
      int_ids,
      int_ids.map {|n| n - ids.index(n)},
    )
  end


  ### OLD CODE
  def two_naive
    int_ids = @bus_ids.filter {|x| x != "x"}.map(&:to_i)
    ids = @bus_ids.map do |x|
      if x == "x"
        x
      else
        x.to_i
      end
    end

    least_frequent_id = T.let(int_ids.max, Integer)
    lfid_offset = ids.find_index(least_frequent_id)

    puts "LF_ID: #{least_frequent_id}, LFID_OFFSET: #{lfid_offset}"

    initial_time = 0
    if @earliest_depart > 10000
      initial_time = 100000000000000
    elsif @earliest_depart > 1000
      initial_time = 1000000000
    end
    puts "Initial time is: #{initial_time}"

    hop_size = ids.size

    loop do
      passed = false

      # scan the range for the lfid
      while initial_time < initial_time+hop_size
        initial_time += 1

        # skip if least frequent is invalid
        next if initial_time % least_frequent_id != 0

        # oh shit, one of these were valid!!!
        passed = true
        break
      end

      next unless passed

      if initial_time > 1068700 && initial_time < 1068794
        puts "Candidate #{initial_time}"
      end

      # passed = true
      passed = ids.each_with_index.all? do |id, offset|
        next true if id == "x"

        next ((initial_time + offset - lfid_offset) % id) == 0
      end

      break if passed
    end

    initial_time - lfid_offset
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    raise unless 1068781 == AoC.new(["1", "7,13,x,x,59,x,31,19"]).two
    # raise
    raise unless 3417 == AoC.new(["1", "17,x,13,19"]).two
    raise unless 754018 == AoC.new(["1", "67,7,59,61"]).two
    raise unless 779210 == AoC.new(["1", "67,x,7,59,61"]).two
    raise unless 1261476 == AoC.new(["1", "67,7,x,59,61"]).two
    raise unless 1202161486 == AoC.new(["1001", "1789,37,47,1889"]).two

    puts "Running main"
    puts "Result: #{runner.two}"
  end
end
main
