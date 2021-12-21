# frozen_string_literal: true
# typed: true

require 'scanf'
require 'matrix'

module CoordSystem
  def x; self[0]; end
  def x=(other); self[0] = other; end
  def y; self[1]; end
  def y=(other); self[1] = other; end
  def z; self[2]; end
  def z=(other); self[2] = other; end
end


class Vector
  attr_accessor :src_scanner
  attr_accessor :src_coord_index
  include CoordSystem

  def manhattan
    map(&:abs).sum
  end
end
class Matrix
  include CoordSystem

  attr_accessor :scanner_index
  alias_method :coords, :column_vectors

  Rotations = [
    # x, y, z
    Matrix[
      [1, 0, 0],
      [0, 1, 0],
      [0, 0, 1],
    ],

    # x, z, y
    Matrix[ [1,0,0], [0,0,1], [0,1,0] ],

    # y, z, x
    Matrix[
      [0, 1, 0],
      [0, 0, 1],
      [1, 0, 0],
    ],

    # y, x, z
    Matrix[ [0,1,0], [1,0,0], [0,0,1] ],

    # z, x, y
    Matrix[
      [0, 0, 1],
      [1, 0, 0],
      [0, 1, 0],
    ],

    # z, y, x
    Matrix[ [0,0,1], [0,1,0], [1,0,0] ],
  ]

  Flippers = [1, -1].repeated_permutation(3).map {Matrix.diagonal(*_1)}
  Orientations = Rotations.product(Flippers).map {|rotation, flip| rotation * flip}.filter{_1.determinant == 1}

  raise unless Orientations.size == 24

  OrientationsCache = {}
  def orientations
    # puts "Using cache" if OrientationsCache[self]
    OrientationsCache[self] ||= Orientations.map {|o| (o * self).column_vectors}
  end
end

class Array
  include CoordSystem

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

  OffsetsCache = {}
  def find_each_offsets(si=nil)
    OffsetsCache[[self,si]] ||= size.times.map do |i|
      self.diffs_from_origin(i, si)
    end
  end

  def diffs_from_origin(idx, si)
    origin = self[idx]
    self.each_with_index.map do |x, i|
      vec = x - origin
      if si
        vec.src_scanner = si
        vec.src_coord_index = i
      else
        vec.src_scanner = x.src_scanner
        vec.src_coord_index = x.src_coord_index
      end
      vec
    end
  end
end

# AoC
class AoC
  def initialize(data)
    @data = data
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
          points = Matrix.columns(points)
          points.scanner_index = id
          @scanners[id] = points
        end

        id = scanner
        points = []
        next
      end
    end


    @scanner_count = @scanners.size


    @scanner_summer = {
      0 => [],
    }
    @oriented_scanner_grids = {
      0 => @scanners.first.column_vectors,
    }
    @spos = {
      0 => Vector[0,0,0]
    }
  end

  def try_merging_offsets(origin_all_offsets)
    is_last = @scanners.size == 1
    puts "Figuring out the last one #{@scanners.map{_1.scanner_index}} - #{origin_all_offsets.first.size}" if is_last

    # Try to solve a scanner
    @scanners.each_with_index do |b_scanner, b_scanner_index|
      # For every possible `a_offsets` (list of offsets from a potential origin in a)
      origin_all_offsets.each_with_index do |a_offsets, a_of_id|

        # For every orientation of that scanner
        b_scanner.orientations.each_with_index do |b_grid, b_or_id|
          b_grid.find_each_offsets(b_scanner.scanner_index).each_with_index do |b_offsets, b_of_id|
            # raise unless b_offsets[b_of_id] == Vector[0,0,0]

            intersections = a_offsets.intersection(b_offsets).size

            if intersections >= 12
              puts "#{intersections} for scanner #{b_scanner.scanner_index}"

              before = Time.now

              # merge b_offsets into a_offsets
              new_offsets = a_offsets.union(b_offsets).find_each_offsets
              puts "Took #{Time.now - before} seconds to recompute origin_all_offsets"

              # Don't keep trying scanners since we've solved it.
              @scanners.delete_at(b_scanner_index)
              @oriented_scanner_grids[b_scanner.scanner_index] = b_grid

              # Find a common offset in b_offsets and a_offsets.
              a_offsets.each do |a|
                b_offsets.each do |b|
                  if a == b

                    tree = @scanner_summer[b.src_scanner] = [a.src_scanner] + @scanner_summer.fetch(a.src_scanner)
                    puts "scanner b:#{b.src_scanner} connected to #{a.src_scanner} — tree is #{tree}"
                    puts

                    b_pinpoint = b_grid[b.src_coord_index]
                    puts "b_pinpoint: #{b_pinpoint}"

                    a_pinpoint = @oriented_scanner_grids[a.src_scanner][a.src_coord_index]
                    puts "a_pinpoint: #{a_pinpoint}"


                    puts "@spos[#{b.src_scanner}] = a_pinpoint - b_pinpoint = #{a_pinpoint - b_pinpoint}"
                    @spos[b.src_scanner] = a_pinpoint - b_pinpoint
                    # puts "#{@spos[a.src_scanner]} - #{b_scanner.coords[b.src_coord_index]} = #{@spos[b.src_scanner].inspect}"
                    # @sdis[b.src_scanner] = ().abs

                    @oriented_scanner_offsets = @spos.map do |si, spo|
                      things_to_sum = @scanner_summer[si]
                      puts "things to sum #{things_to_sum}"
                      puts "#{spo}"
                      [spo, *things_to_sum.map {@spos[_1]}].inject(&:+)
                    end

                    puts "@spos is now #{@spos}"
                    puts; puts
                    completed = @scanner_count - @scanners.size
                    left = @scanners.size
                    percent = (completed.to_f / @scanner_count) * 100
                    elapsed = Time.now - @start_time
                    elapsed_minutes = (elapsed / 60).round(2)
                    puts "PROGRESS: #{completed} of #{@scanner_count} completed, #{left} left, #{percent}% - #{elapsed} seconds elapsed (#{elapsed_minutes} minutes)"
                    puts; puts;
                    return new_offsets
                  end
                end
              end


              # original_a = @origin_scanner_coords[a_of_id]
              # puts "#a_of_id is #{a_of_id.inspect} and #{original_a.inspect}"

              # Given offset(of_id)

              # diff = b_grid[b_of_id] - a_offsets[a_of_id]
              # @oriented_scanner_offsets << diff

              return new_offsets
            end
          end
        end

      end

    end
    nil
  end

  def one
    parse

    @start_time = Time.now
    @origin_scanner_coords = @scanners.shift.coords

    # there is no one origin_grid_offsets,
    # as each coordinate in the origin scanner can be an origin
    origin_all_offsets = @origin_scanner_coords.find_each_offsets(0)

    while !@scanners.empty?
      origin_all_offsets = try_merging_offsets(origin_all_offsets)
      if !origin_all_offsets
        raise "Could not solve these scanners: #{@scanners.map {_1.scanner_index}}"
      end
    end

    puts "Taken #{Time.now - @start_time} seconds to complete"
    @offsets = origin_all_offsets.first.to_a.sort3
    origin_all_offsets.first.size
  end

  def two
    puts "oriented scanner offsets: #{@oriented_scanner_offsets}"
    differences = @oriented_scanner_offsets.combination(2).map {|a, b| (b - a).manhattan}.max
    # differences = @sdis.values.combination(2).map {|a, b| b - a}.map(&:abs).max
    # puts "differences between each #{differences}"
    differences
  end
end

def test(part)
  examples = [
    79,
    3621,
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
