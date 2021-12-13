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
    puts "folding y=#{y}"
    # raise "not odd" if (grid.size % 2) == 0

    top = grid[...y]
    folded_bottom = grid[y+1...].reverse

    if (rs = folded_bottom.size) < (rl = top.size)
      cut_amount = rl - rs
      extra = Array.new(cut_amount) { Array.new(top.first.size, false)}
      # puts "extra: #{extra}"
      folded_bottom = extra + folded_bottom
    end

    # print_grid(top)
    # print_grid(folded_bottom.reverse)
    raise "??? top size = #{top.size}, bottom=#{folded_bottom.size}" unless top.size == folded_bottom.size

    top.each_with_index do |row, y|
      row.each_with_index do |tv, x|
        top[y][x] ||= folded_bottom[y][x]
      end
    end

    top
  end

  # modifies array.
  def fold_x(grid, x)
    puts "folding x=#{x} (max_x=#{@max_x})"
    grid.map do |row|
      # raise "not odd" if (row.size % 2) == 0

      left = row[...x]
      folded_right = row[x+1...].reverse

      if (rs = folded_right.size) < (rl = left.size)
        cut_amount = rl - rs
        extra = Array.new(cut_amount, false)
        # puts "extra: #{extra}"
        folded_right = extra + folded_right
      end

      raise "??? left size = #{left.size}, right=#{folded_right.size}" unless left.size == folded_right.size
      left.zip(folded_right).map {_1.inject(&:|)}
    end
  end

  def one(testing=false)
    grid = make_space([], @max_x, @max_y, default: false)
    @input.each do |(x, y)|
      grid[y][x] = true
    end

    first_count = nil

    print_grid(grid) if testing

    @folds_xy.each_with_index do |(x, y), iter|
      grid = if x
          fold_x(grid, x)
        elsif y
          fold_y(grid, y)
        else
          raise "???"
        end
      print_grid(grid) if testing

      if iter == 0
        first_count = grid.sum {|row| row.count {_1}}
        # break unless testing
      end
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
