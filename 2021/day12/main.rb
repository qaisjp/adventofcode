# frozen_string_literal: true
# typed: true


require 'set'

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    @data = data.each_with_object({}) do |pair, h|
      l, r = pair.split("-")
      (h[l] ||= []) << r
      (h[r] ||= []) << l
    end
    @one_only = @data.keys.filter {_1 == _1.downcase}.to_set
    @routes = []
  end

  def travel(start, route, multi)
    if @one_only.include?(start)
      if start == multi
        c = route.count(start)
        return if c == 2
        raise "????" if c > 2
      else
        # stop if we aren't allowed to visit this one again
        return if route.include?(start)
      end
    end
    route << start

    if start == "end"
      @routes << route
      return # do nothing
    end

    next_places = @data[start]
    if !next_places
      puts "#{start} is terminal"
      return
    end

    next_places.each do |place|
      travel(place, route.dup, multi)
    end
  end

  def one
    # puts "#{@data}"
    travel("start", [], nil)
    # puts "#{@routes}"


    @routes.size
  end

  def two
    @routes = []

    @data.keys.each do |multi|
      next if multi == "start" || multi == "end"
      travel("start", [], multi)
    end

    @routes.uniq.size
  end
end

def test(part, f:, examples:)
  runner = AoC.new File.read(f).split("\n")

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
  run_both = true

  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  if !test(n, f: "example.txt", examples: [10, 36])
    puts "\n====Tests 1 failed :(====\n\n"
    # return
  end
  if !test(n, f: "example2.txt", examples: [19, 103])
    puts "\n====Tests 2 failed :(====\n\n"
    # return
  end
  if !test(n, f: "example3.txt", examples: [226, 3509])
    puts "\n====Tests 3 failed :(====\n\n"
    # return
  end

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Result: #{runner.one}"
  end
  if n == '2'
    puts "Result: #{runner.two}"
  end
end

main
