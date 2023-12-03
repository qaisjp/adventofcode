# frozen_string_literal: true
# typed: true

require 'pry'
require 'scanf'
require 'set'
require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    # @data = T.let(data.first, String)
    @data = T.let(data, T::Array[String])
  end

  Coord = T.type_alias { [Integer, Integer] }

  EG1 = 4361

  class Chunk < T::Struct
    prop :num, Integer
    prop :coords, T::Array[Coord]
  end

  sig {params(str: String).returns(T::Boolean)}
  def isint(str)
    begin
      Integer(str)
      true
    rescue ArgumentError
      false
    end
  end

  def around(coords)
    [
      # top left
      [coords[0] - 1, coords[1] - 1],
      # top
      [coords[0] - 1, coords[1]],
      # top right
      [coords[0] - 1, coords[1] + 1],

      # middle left
      [coords[0], coords[1] - 1],
      # middle right
      [coords[0], coords[1] + 1],

      # bottom left
      [coords[0] + 1, coords[1] - 1],
      # bottom middle
      [coords[0] + 1, coords[1]],
      # bottom right
      [coords[0] + 1, coords[1] + 1],
  ].reject do |y, x|
      y < 0 || x < 0 || y >= @data.length || x >= @data[y].length
    end
  end

  def one
    chunks = T::Array[Chunk].new
    symbol_coords = []

    @data.each_with_index do |line, y|
      cur_num = T.let(nil, T.nilable(String))
      cur_coords = []
      line.chars.each_with_index do |char, x|

        if isint(char)
          cur_num ||= ""
          cur_num += char
          cur_coords << [y, x]
        else
          if char != "."
            symbol_coords << [y, x]
          end

          if cur_num
            chunks << Chunk.new(num: cur_num.to_i, coords: cur_coords)
          end
          cur_num = nil
          cur_coords = []
        end
      end

      if cur_num
        chunks << Chunk.new(num: cur_num.to_i, coords: cur_coords)
      end
      cur_num = nil
      cur_coords = []
    end

    find_coords = symbol_coords.map do |y, x|
      around([y, x])
    end.flatten(1)

    our_chunks = chunks.filter do |chunk|
      chunk.coords.any? do |coord|
        find_coords.include?(coord)
      end
    end

    puts "chunks: #{our_chunks}"

    

    # binding.pry

    our_chunks.sum(&:num)
  end

  EG2 = 0
  def two
    0
  end
end

#####
##### BOILERPLATE
#####

def test(_part)
  runner = AoC.new File.read('example.txt').split("\n")

  one = runner.one
  this = AoC::EG1
  if one != this
    puts "Example part 1 was #{one}, expected #{this}"
  else
    puts "Example part 1 passes (#{one})"
    passed = true
  end

  if passed
    puts "\n\n--- Example part 2"
    two = runner.two
    this = AoC::EG2
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
  run_both = T.let(false, T::Boolean)

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

  puts "\n\n--- Part #{n} solution" if n != nil
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two}"
  end
end

main
