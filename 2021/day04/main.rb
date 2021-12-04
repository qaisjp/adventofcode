# frozen_string_literal: true
# typed: true

# require 'sorbet-runtime'
require 'set'

# AoC
class AoC
  # extend T::Sig

  def initialize(data)
    parts = data.split("\n\n")

    @numbers = parts.shift.split(",").map(&:to_i)
    @grids = parts.map do
      _1.split("\n").map(&:split).map do |inner|
        inner.map(&:to_i).map {|n| [n, false]}
      end
    end

    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data, T::Array[String])
  end

  def mark(grids, num)
    # potential bulk mark optimisation possible here
    grids.each do |grid|
      grid.each do |row|
        row.each do |pair|
          thisnum, _ = pair
          if thisnum == num
            pair[1] = true
          end
        end
      end
    end
  end

  def print_grid(grid)
    print_grids([grid])
  end

  def print_grids(grids)
    row_count = grids.first.size
    puts
    row_count.times do |row|
      rows = grids.map {_1[row]}
      rows.map! do |row|
        row.map do |pair|
          num, hit = pair
          s = ""
          if hit
            s = "\033[31m"
          end
          s += sprintf("%2d", num)
          if hit
            s += "\033[0m"
          end
          s
        end.join(" ")
      end
      puts rows.join("\t\t")
    end
    puts
  end

  def find_bingo(grids, except=[])
    winners = Set[]

    grids.each_with_index do |grid, grid_index|
      next if except.include? grid_index

      column_hits = grid.first.map{_1[1]}
      grid.each do |row|
        # BINGO!
        if row.map{_1[1]}.to_set.to_a == [true]
          winners << grid_index
        end

        row.each_with_index do |pair, i|
          _, hit = pair
          if !hit
            column_hits[i] = false
          end
        end
      end

      if column_hits.filter {_1}.to_a == [true]
        winners << grid_index
      end
    end

    # if winners.size > 1
    #   puts "winners: #{winners}"
    # end

    winners
  end

  def clear_hits
    @grids.each do |grid|
      grid.each do |row|
        row.each do |pair|
          pair[1] = false
        end
      end
    end
  end

  def one
    winning_grid = nil
    last_number = nil
    @numbers.each do |called_number|
      mark(@grids, called_number)
      find_bingo(@grids).each do |winner|
        winning_grid = winner
        last_number = called_number
        break
      end

      break if winning_grid
    end

    if !winning_grid
      raise "no winning grid"
    end

    sum = count_marked(@grids[winning_grid])

    puts "winning grid is grid #{winning_grid}: #{sum} * #{last_number}"
    print_grid(@grids[winning_grid])

    clear_hits
    sum * last_number
  end

  def count_marked(grid)
    sum = 0
    grid.each do |row|
      row.each do |pair|
        n, hit = pair
        if !hit
          sum += n
        end
      end
    end
    sum
  end

  def two
    winners = []
    winning_called = []
    winning_sums = []
    @numbers.each do |called_number|
      mark(@grids, called_number)
      find_bingo(@grids, winners).each do |winning_grid|
        puts "BINGO! #{winning_grid} with #{called_number}"
        winners << winning_grid
        winning_called << called_number
        winning_sums << count_marked(@grids[winning_grid])
      end
    end

    winning_grid = winners.last
    last_number = winning_called.last
    sum = winning_sums.last
    if winning_grid.nil?
      raise "no winning grid"
    end

    puts "#{winning_grid} won. number called was #{last_number}, sum #{sum}"
    sum * last_number
  end
end

$examples = [
  4512,
  1924,
]

def test(part)
  runner = AoC.new File.read("example.txt")

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

  test(n)

  if n == '1' or n == '2'
    if ARGV.empty?
      runner = AoC.new File.read("input.txt")
    else
      runner = AoC.new ARGF.read
    end
  end

  puts "\n\n--- Part #{n} solution"
  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end

main
