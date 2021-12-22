# frozen_string_literal: true
# typed: true

require 'set'
require 'scanf'

# From https://stackoverflow.com/a/8414606/1517394
class Range
  def intersection(other)
    raise ArgumentError, 'value must be a Range' unless other.kind_of?(Range)

    new_min = self.cover?(other.min) ? other.min : other.cover?(min) ? min : nil
    new_max = self.cover?(other.max) ? other.max : other.cover?(max) ? max : nil

    new_min && new_max ? new_min..new_max : nil
  end

  # def remove_intersection(other)
  #   inter = intersection(other)
  #   result = []

  #   # self is 2..5
  #   # other is 3..6
  #   # return
  #   result
  # end

  # function to remove a subrange from a range, returning 1 or 2 new ranges
  def delete_subrange(subrange)
    result = []

    min_in_range = cover?(subrange.min)
    max_in_range = cover?(subrange.max)
    if min_in_range && max_in_range
      # -20            20
      #       -2..2
      result << (self.begin..(subrange.begin - 1))
      result << ((subrange.end + 1)..self.end)
    elsif !(min_in_range && max_in_range)
      # -20     20
      #             30 ... 40
      result << self
    elsif min_in_range
      # -20            20
      #       -2   ..     30

      result << (min .. (subrange.min - 1))
    elsif self.cover?(subrange.max)
      #        -10            20
      #  -20   ..     10
      result << ((subrange.min + 1) .. self.max)
    end

    result2 = result.filter {_1.begin < _1.end}
    puts "#{result} became #{result2} for cutting #{subrange} from #{self}" if result != result2
    # puts "real result is #{result}"
    result2
  end

  alias_method :&, :intersection
end

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data.map do |line|
      next if line == ""
      state, rest = /(on|off) (.*)/.match(line).to_a[1..]
      # puts "#{/(on|off) .*/.match(line).to_a}"
      xa, xb, ya, yb, za, zb = rest.scanf('x=%d..%d,y=%d..%d,z=%d..%d')
      raise unless state == "on" || state == "off"
      [state=="on", (xa..xb), (ya..yb), (za..zb)]
    end
  end

  def one
    xfix = (-50..50)
    yfix = (-50..50)
    zfix = (-50..50)

    onners = Set[]

    @data.each do |line|
      state, xr, yr, zr = line

      xr = xfix & xr
      yr = yfix & yr
      zr = zfix & zr

      next unless xr && yr && zr

      if state
        onners << [xr, yr, zr]
      else
        onners.flat_map do |ranges|
          res = []
          ranges[0].delete_subrange(xr).each do |x|
            ranges[1].delete_subrange(yr).each do |y|
              ranges[2].delete_subrange(zr).each do |z|
                res << [x, y, z]
              end
            end
          end
          res
        end
      end
    end

    grid = Set[]
    onners.each do |ranges|
      ranges[0].each do |x|
        ranges[1].each do |y|
          ranges[2].each do |z|
            grid << [x, y, z]
          end
        end
      end
    end

    # onners.map {|x, y, z| x.size * y.size * z.size}.sum
    grid.size
  end

  def two

    0
  end
end

def test(part)
  examples = [
    590784,
    0,
  ]

  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = examples.last
    if two != this
      puts "\n\nExample part 2 was #{two}, expected #{this}"
      passed = false
    else
      puts "\n\nExample part 2 passes (#{this})"
    end
  end

  passed
end

def main
  run_both = false

  n = ARGV.shift

  if !test(n)
    puts "Tests failed :("
    return
  end

  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
