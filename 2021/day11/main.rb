# frozen_string_literal: true
# typed: true

# AoC
class AoC

  def initialize(data)
    # @data = data.map(&:to_i)
    @grid = data.map {_1.chars.map(&:to_i)}
    @row_size = @grid.first.size
    @first_full_flash = nil
  end

  # copied from day 9, slightly modified
  def adjacents(y, x, coords: true, &blk)
    _coords = [
      [y-1, x],
      [y+1, x],
      [y, x-1],
      [y, x+1],

      # diagonals
      [y-1, x-1], # tl
      [y-1, x+1], # tr
      [y+1, x-1], # bl
      [y+1, x+1], # br
    ]

    results = []
    _coords.each do |coord|
      y, x = coord
      next if y < 0 || y >= @grid.size
      next if x < 0 || x >= @row_size

      if coords
        val = [y, x]
      else
        val = @grid[y][x]
      end

      if blk
        conditional = blk.call(y, x, @grid[y][x])
        if conditional
          results << val
        end
      else
        results << val
      end
    end
    results
  end

  def print_grid(grid)
    puts
    grid.each do |row|
      str = row.map do |num|
        if num.nil?
          "\033[31m0\033[0m"
        else
          num
        end
      end.join
      puts str
    end
    puts
  end

  def iter(stepno)
    # increment each except flashed
    @grid.each_with_index do |row, y|
      row.map! do |n|
        n&.+(1)
      end
    end

    grid_changed = true
    flashes = 0
    while grid_changed
      grid_changed = false
      @grid.each_with_index do |row, y|
        row.size.times do |x|
          num = @grid[y][x]
          if num&.>(9)
            grid_changed = true
            @grid[y][x] = nil # flash!
            flashes += 1

            adjacents(y, x).each do |(adjy, adjx)|
              @grid[adjy][adjx] = @grid[adjy][adjx]&.+(1)
            end
          end
        end
      end
    end

    # set any nils to 0
    @grid.each_with_index do |row, y|
      row.map! do |n|
        if n
          stepno = nil
        end
        n || 0
      end
    end

    @first_full_flash ||= stepno if stepno

    flashes
  end

  def one
    flashes = 0

    print_grid(@grid)

    (1..).each do |i|
      lflash = iter(i)
      if i <= 100
        flashes += lflash
      end

      break if @first_full_flash
    end

    flashes
  end

  def two
    @first_full_flash
  end
end

def test(part)
  examples = [
    1656,
    195,
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
