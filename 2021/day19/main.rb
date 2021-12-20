# frozen_string_literal: true
# typed: true

require 'scanf'
require 'matrix'
require 'set'

module CoordSystem
  def x; self[0]; end
  def x=(other); self[0] = other; end
  def y; self[1]; end
  def y=(other); self[1] = other; end
  def z; self[2]; end
  def z=(other); self[2] = other; end
end

module VectorCommon
end

module GridCommon
  def diffs_from_origin(idx)
    arr = if self.class == Array
        self
      elsif self.class == Matrix
        self.coords
      else
        raise "diffs_from_origin on Array[Vector] or Matrix only"
      end

    origin = arr[idx]
    cols = arr.map do |x|
      x - origin
    end

    # if self.class == Matrix
    #   Matrix.columns(cols)
    # else
    cols
    # end
  end
end

class Vector; include CoordSystem; include VectorCommon; end
class Matrix
  include CoordSystem
  include VectorCommon
  include GridCommon

  attr_accessor :scanner_index
  alias_method :coords, :column_vectors

  def find_each_offsets
    column_count.times.map do |i|
      self.diffs_from_origin(i)
    end
  end

  Rotations = [
    # x, y, z
    Matrix[
      [1, 0, 0],
      [0, 1, 0],
      [0, 0, 1],
    ],

    # y, z, x
    Matrix[
      [0, 1, 0],
      [0, 0, 1],
      [1, 0, 0],
    ],

    # z, x, y
    Matrix[
      [0, 0, 1],
      [1, 0, 0],
      [0, 1, 0],
    ],
  ]

  Flippers = [1, -1].repeated_permutation(3).map {Matrix.diagonal(*_1)}
  Orientations = Rotations.product(Flippers).lazy

  OrientationsCache = {}
  def orientations
    # puts "Using cache" if OrientationsCache[self]
    OrientationsCache[self] ||= Orientations.map {|rotation, flip| rotation * flip * self}
  end
end

class Array
  include CoordSystem
  include GridCommon

  def sort3
    sort do |a, b|
      if (r = a.x <=> b.x) != 0
        r
      elsif (r = a.y <=> b.y) != 0
        r
      else
        a.z <=> b.z
      end
    end
  end
end

# AoC
class AoC
  def initialize(data)
    # @data = data.map(&:to_i)
    # @data = data.first
    @data = data
  end

  def count_common_points(as, bs)
    as = as.tally
    bs = bs.tally
    as.sum do |key, count_a|
      count_b = bs.fetch(key, 0)
      [count_a, count_b].min
    end
  end

  def parse
    id = nil
    points = nil

    @scanners = []
    last_index = @data.size - 1
    @data.each_with_index do |line, i|
      coord = line.scanf("%d,%d,%d")
      points << Vector[*coord] if coord.size != 0

      scanner = line.scanf("--- scanner %d ---").first
      if scanner || i == last_index
        if id
          points = Matrix.columns(points.sort3)
          points.scanner_index = id
          # puts "scanner loaded #{points.scanner_index}"
          # puts "--- scanner #{id} ---"
          # puts points.column_vectors.map {|coord|"#{coord.x},#{coord.y},#{coord.z}"}
          # puts
          @scanners[id] = points
        end

        id = scanner
        points = []
        next
      end
    end
  end

  def one
    parse

    origin_scanner = @scanners.shift

    # there is no one origin_grid_offsets,
    # as each coordinate in the origin scanner can be an origin
    origin_all_offsets = origin_scanner.find_each_offsets
    # raise "!" unless origin_all_offsets == Matrix.columns(origin_all_offsets.first).find_each_offsets

    example = [
      Vector[0, 1, 0],
      Vector[1, 2, 3],
      Vector[-1, 9, -3],
    ].sort3

    while !@scanners.empty?
      solved = false

      # For every possible `a_offsets` (list of offsets from a potential origin in a)
      origin_all_offsets.each_with_index do |a_offsets, a_origin_index|
        break if solved

        # For every unsolved scanner
        @scanners.each_with_index do |b_scanner, b_scanner_index|
          found_offsets = nil

          # For every orientation of that scanner
          b_scanner.orientations.each do |b_grid|
            break if found_offsets
            b_grid.find_each_offsets.each do |b_offsets|
              intersections = a_offsets.intersection(b_offsets).size
              if intersections >= 12
                puts "#{intersections} for scanner #{b_scanner.scanner_index} against scanner 0"
                found_offsets = b_offsets
                break
              end
            end
          end

          if found_offsets
            # merge a_offsets into found_offsets
            origin_all_offsets = Matrix.columns(a_offsets.union(found_offsets)).find_each_offsets

            # Don't keep trying scanners since we've solved it.
            @scanners.delete_at(b_scanner_index)
            solved = true
            break
          end
        end
      end

    end

    origin_all_offsets.first.size
  end

  def two

    0
  end
end

def test(part)
  examples = [
    0,
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
