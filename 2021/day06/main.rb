# frozen_string_literal: true
# typed: true

# AoC
class AoC

  def initialize(data)
    @data = data.first.split(",").map(&:to_i)
    # @data = data
  end

  def algo_one(days)
    fish = @data.dup

    initial_day = fish.dup
    initial_size = initial_day.size

    puts "Initial state: #{fish.join(",")}"

    days.times do |day|
      push_fish = 0
      fish.map! do |t|
        t = t - 1
        if t == -1
          t = 6
          push_fish += 1
        end
        t
      end
      fish.concat(Array.new(push_fish, 8))

    end

    fish.count
  end

  def algo_two(days)
    fish = @data.dup

    counts = fish.tally

    days.times do |day|
      counts = counts.each_with_object(Hash.new(0)) do |p, res|
        n, count = p
        if n == 0
          res[6] = res.fetch(6, 0) + count
          res[8] = count
        else
          res[n - 1] = res.fetch(n - 1, 0) + count
        end
      end
    end

    counts.values.sum
  end

  def one
    algo_two(80)
  end

  def two
    algo_two(256)
  end
end

$examples = [
  5934,
  26984457539,
]

def test(part)
  runner = AoC.new File.read("example.txt").split("\n")

  one = runner.one
  this = $examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = $examples[1]
    if two != this
      puts "\n\nExample part 2 was #{two}, expected #{this}"
    else
      puts "\n\nExample part 2 passes (#{this})"
    end
  end
end

def main
  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  test(n)

  puts "\n\n--- Part #{n} solution"
  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end

main
