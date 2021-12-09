# frozen_string_literal: true
# typed: true

# AoC
class AoC

  def initialize(data)
    @grid = data.map {_1.chars.map(&:to_i)}
    @row_size = @grid.first.size
  end

  def adjacents(y, x, coords: false, &blk)
    _coords = [
      [y-1, x],
      [y+1, x],
      [y, x-1],
      [y, x+1],
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

  def adjacents_lower(y, x)
    this = @grid[y][x]
    adjacents(y, x, coords: true) { _3 < this }
  end

  def is_lowest(y, x)
    num = @grid[y][x]
    # check if this num is >= any any adjacent values
    adjacents(y, x) { num >= _3 }.empty?
  end

  def one
    total = 0

    @grid.each_with_index do |row, y|
      row.each_with_index do |num, x|
        if is_lowest(y, x)
          # puts "#{y}, #{x} is lowest"
          total += num + 1
        end
      end
    end

    total
  end

  def new_basin_matrix
    @grid.map {_1.map {0}}
  end

  def two
    matrix = new_basin_matrix

    # for each location...
    @grid.each_with_index do |row, y|
      row.each_with_index do |num, x|
        # 9 is a wall, don't mark this point
        next if num == 9
        matrix[y][x] = 1
      end
    end

    # puts "#{matrix.map(&:join).join("\n")}"
    # puts

    island_sizes = []

    # for each location
    @grid.each_with_index do |row, y|
      row.each_with_index do |num, x|

        # nothing to infect if this isn't a basin
        next if matrix[y][x] == 0

        # so this is a random spot in a basin.
        size = 1
        matrix[y][x] = 0

        # puts "On #{y}, #{x}"
        # puts "#{matrix.map(&:join).join("\n")}"
        # puts

        # start infecting/exploring the basin
        adjacents_to_explore = []
        currently_exploring = adjacents(y, x, coords: true) { |y, x, num| matrix[y][x] == 1 }
        # puts "Starts exploring #{currently_exploring}"
        while !currently_exploring.empty?
          new_adjacents = []

          currently_exploring.each do |y, x|
            next if matrix[y][x] == 0 # this might have been visited already in an earlier iteration
            matrix[y][x] = 0
            size += 1
            this_adjacents = adjacents(y, x, coords: true) { |y, x, num| matrix[y][x] == 1 }
            new_adjacents += this_adjacents
            # puts "On #{y},#{x}, this #{this_adjacents}"
          end

          currently_exploring = new_adjacents
        end

        # puts "Size of island at #{y},#{x} is #{size}"

        island_sizes << size
      end
    end

    island_sizes.sort.reverse[0..2].inject(:*)
  end
end

$examples = [
  15,
  1134,
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
