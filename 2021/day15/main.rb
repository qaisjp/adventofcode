# frozen_string_literal: true
# typed: true

require 'set'

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    @cost = data.map{_1.chars.map(&:to_i)}
    @row_size = @cost.first.size
    @row_count = @cost.size
  end

  # copied from day 11, slightly modified
  def adjacents(y, x, coords: true, diagonals: false, &blk)
    _coords = [
      [y-1, x],
      [y+1, x],
      [y, x-1],
      [y, x+1],
    ]

    if diagonals
      _coords += [
        # diagonals
        [y-1, x-1], # tl
        [y-1, x+1], # tr
        [y+1, x-1], # bl
        [y+1, x+1], # br
      ]
    end

    results = []
    _coords.each do |coord|
      y, x = coord
      next if y < 0 || y >= @cost.size
      next if x < 0 || x >= @row_size

      if coords
        val = [y, x]
      else
        val = @cost[y][x]
      end

      if blk
        conditional = blk.call(y, x, @cost[y][x])
        if conditional
          results << val
        end
      else
        results << val
      end
    end
    results
  end

  def reconstruct_path(cameFrom, current)
    total_path = [current]
    while cameFrom[current]
      current = cameFrom[current]
      total_path << current
    end
    total_path.reverse
  end

  def a_star
    start = [0, 0]
    goal = [@cost.size - 1, @cost.first.size - 1]

    frontier = {start => 0}
    cameFrom = {}

    cost_so_far = {start => 0}

    while !frontier.empty?
      current, _ = frontier.min_by {|k, v| v}
      frontier.delete(current)
      y, x = current

      if current == goal
        return reconstruct_path(cameFrom, current)
      end

      adjacents(y, x).each do |neighbour|
        ny, nx = neighbour
        new_cost = cost_so_far[current] + @cost[ny].fetch(nx)
        if cost_so_far[neighbour].nil? || (new_cost < cost_so_far[neighbour])
          cost_so_far[neighbour] = new_cost
          frontier[neighbour] = new_cost
          cameFrom[neighbour] = current
        end
      end

    end

    raise "no route?!"
  end

  def calculate_risk(route)
    route.sum do |(y, x)|
      if y+x == 0
        0
      else
        @cost[y][x]
      end
    end
  end

  # def enlarge_row(row)
  #   flatten = [row]
  #   5.times do
  #     flatten << flatten.last.map {|n| (n >= 9) ? 1 : (n + 1)}
  #   end
  #   flatten.flatten
  # end

  # def enlarge_column(grid)
  #   flatten = [grid]
  #   5.times do
  #     flatten << flatten.last
  #   end
  #   flatten.flatten
  # end

  def find_cost(coord)
    y, x = coord
    real_y = y % @row_count
    real_x = x % @row_size
    cost = @cost[real_y].fetch(real_x)

    adding = (y / @row_count) + (x / @row_size)

    mod = (cost + adding) % 9
    if mod == 0
      9
    else
      mod
    end
  end

  def one
    calculate_risk(a_star)
  end

  def two
    new_cost = Array.new(@row_count * 5) {
      Array.new(@row_size * 5, 0)
    }

    puts((@row_count * 5).times.map do |y|
      row = (@row_size * 5).times.map do |x|
        new_cost[y][x] = find_cost([y,x])
      end
      row.join
    end.join("\n"))

    @row_count *= 5
    @row_size *= 5

    @cost = new_cost

    one
  end
end

def test(part)
  examples = [
    40,
    315,
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
  run_both = true

  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  if !test(n)
    puts "Tests failed :("
    return
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
