# frozen_string_literal: true
# typed: true

require 'scanf'

# AoC
class AoC

  def initialize(data)
    @max_x = 0
    @max_y = 0
    @input = data.first.split("\n").map do
      x, y = _1.split(",").map(&:to_i)
      @max_x = [@max_x, x].max
      @max_y = [@max_y, y].max
      [x, y]
    end
    @folds_xy = data.last.split("\n").map do |line|
      y = line.scanf("fold along y=%d").first
      x = line.scanf("fold along x=%d").first
      if x
        [x, nil]
      else
        [nil, y]
      end
    end
  end

  def make_space(grid, x, y, default: nil)
    (0..y).each do |y|
      grid[y] ||= []
      (0..x).each do |x|
        grid[y][x] ||= default
      end
    end
    grid
  end

  # modifies array.
  def fold_y(grid, y)
    top = grid[...y]
    bottom = grid[y+1...]
    bottom += Array.new(top.size - bottom.size) { Array.new(top.first.size, false)}

    raise "??? top size = #{top.size}, bottom=#{bottom.size}" unless top.size == bottom.size

    bottom = bottom.reverse
    top.size.times do |y|
      top[y] = top[y].zip(bottom[y]).map {_1.inject(&:|)}
    end

    top
  end

  # might modify array.
  def fold_x(grid, x)
    grid.map do |row|
      left = row[...x]
      right = row[x+1...]
      right += Array.new(left.size - right.size, false)
      raise "??? left size = #{left.size}, right=#{right.size}" unless left.size == right.size
      left.zip(right.reverse).map {_1.inject(&:|)}
    end
  end

  def one(testing=false)
    grid = make_space([], @max_x, @max_y, default: false)
    @input.each do |(x, y)|
      grid[y][x] = true
    end

    first_count = nil

    @folds_xy.each_with_index do |(x, y), iter|
      grid = if x
          fold_x(grid, x)
        elsif y
          fold_y(grid, y)
        else
          raise "???"
        end
      first_count = grid.sum {|row| row.count {_1}} if iter == 0
    end

    print_grid(grid)

    first_count
  end

  def print_grid(grid)
    puts
    grid.each do |row|
      str = row.map do |v|
        if v
          "#"
        else
          "."
        end
      end.join
      puts str
    end
    puts
  end
end

def test(part)
  examples = [
    17,
    0,
  ]

  runner = AoC.new File.read("example.txt").split("\n\n")

  one = runner.one(true)
  this = examples.first
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  passed
end

def main
  run_both = true

  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").split("\n\n")
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
end

main
