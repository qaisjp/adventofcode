# frozen_string_literal: true
# typed: true

require 'scanf'
require 'set'
require 'sorbet-runtime'
require 'pry'

# https://gist.github.com/senorprogrammer/1058413
class Range
  def intersection(other)
    raise ArgumentError.new("Should all be exclude the end!") unless other.exclude_end? && self.exclude_end?

    my_min, my_max = first, exclude_end? ? max : last
    other_min, other_max = other.first, other.exclude_end? ? other.max : other.last

    new_min = self === other_min ? other_min : other === my_min ? my_min : nil
    new_max = self === other_max ? other_max : other === my_max ? my_max : nil

    new_min && new_max ? new_min...(new_max+1) : nil
  end
  alias_method :&, :intersection
end


# AoC
class AoC
  extend T::Sig
  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @seeds = T.let(T.let(data.first, String).delete_prefix("seeds: ").split.map(&:to_i), T::Array[Integer])
    @maps = T.let(data[1..], T::Array[String])
  end

  def num_for_cat(cat, num)
    catmap = T.let(@category_map, T::Hash[String, T::Hash[Range, Range]])
    range_rules = T.must(catmap[cat])

    src_rng, dst_rng = range_rules.find do |src_rng, dst_rng|
      src_rng.include?(num)
    end

    if !src_rng
      return num
    end

    offset = num - src_rng.begin
    dst_rng.begin + offset
  end

  EG1 = 35
  def one
    # puts(@seeds)

    @category_map = T::Hash[String, T::Hash[Range, Range]].new do |h, k|
      h[k] = T::Hash[Range, Range].new
    end

    @categories = %w[seed soil fertilizer water light temperature humidity location]
    
    @maps.each do |map|
      header, *rest = map.split("\n")
      src_cat, dst_cat = T.must(header).gsub("-to-", " ").scanf("%s %s")

      rest.each do |line|
        dst_rng_start, src_rng_start, rng_len = line.scanf("%d %d %d")

        @category_map[src_cat][src_rng_start ... (src_rng_start + rng_len)] = dst_rng_start ... (dst_rng_start + rng_len)
      end
    end

    @seeds.map do |seed|
      curno = seed
      @categories.each do |cat|
        curno = num_for_cat(cat, curno)
      end
      # puts("For seed #{seed} got #{curno}")
      curno
    end.min
  end

  def two_brute
    seed_rngs = @seeds.each_slice(2).map do |start, len|
      (start ... (start + len))
    end

    
    puts("one is done... #{one}")
    seed_rngs.map do |rng|
      puts("Working on #{rng}")
      rng.map do |seed|
        curno = seed
        @categories.each do |cat|
          curno = num_for_cat(cat, curno)
        end
        # puts("For seed #{seed} got #{curno}")
        curno
      end
    end.flatten(1).min
  end

  # Rewrite range (1...11) giving a remap rule of (4...9) -> (12...19)
  #
  # Will return {
  #   (1...4)  -> (1...4),     (aka front)
  #   (4...9)  -> (12...17),   (aka intersecting)
  #   (9...11) -> (9...11)    (aka back)
  # }
  sig {params(rng: T::Range[Integer], from: T::Range[Integer], to: T::Range[Integer]).returns(T::Hash[T::Range[Integer],T::Range[Integer]])}
  def range_remap(rng, from, to)
    raise ArgumentError.new("Should all be endless!") unless rng.exclude_end? && from.exclude_end? && to.exclude_end?

    if rng.begin < from.begin
      front = (rng.begin ... from.begin) & rng
    end

    if rng.end > from.end
      back = (from.end ... rng.end) & rng
    end

    # i.e. (4...9)
    intersecting = rng & from

    # Then remap intersecting
    if intersecting
      offset_from_start = intersecting.begin - from.begin
      new_intersecting = (to.begin + offset_from_start) ... (to.begin + offset_from_start + intersecting.size)
    end

    result = [
      [front, front],
      [intersecting, new_intersecting],
      [back, back],
    ]

    result.to_h.compact
  end

  def test_range_remap
    result = range_remap(
      (1...11),
      # from
      (4...9),
      # to
      (12...9)
    )
    if result != {
      (1...4)  => (1...4),
      (4...9)  => (12...17),
      (9...11) => (9...11)
    }
      raise("Test 1 failed for test_range_remap got #{result.inspect} instead")
    end

    result2 = range_remap(
      (1...4),
      # from
      (6...9),
      # to
      (13...9)
    )
    if result2 != {
      (1...4)  => (1...4),
    }
      raise("Test 2 failed for test_range_remap got #{result2.inspect} instead")
    end
  end

  EG2 = 46
  def two
    puts("Seeds was #{@seeds.inspect}")

    seed_rngs = @seeds.each_slice(2).map do |start, len|
      (start ... (start + len))
    end

    range_map = T::Hash[Range, Range].new

    # update range_map with itself for now
    seed_rngs.each do |seed_rng|
      range_map[seed_rng] = seed_rng
    end



    @maps.each do |map|
      header, *rest = map.split("\n")
      # src_cat, dst_cat = T.must(header).gsub("-to-", " ").scanf("%s %s")

      new_range_map = T::Hash[Range, Range].new
      puts("\n\n# #{header}")
      puts("Range map is currently #{range_map.inspect}")

      T.must(rest).each do |line|
        # puts("## #{line}")
        dst_rng_start, src_rng_start, rng_len = T.let(line.scanf("%d %d %d"), [Integer, Integer, Integer])

        #                                      seed      soil
        # if the current range map looks like (2...9) -> (12...19)
        #
        #                                         soil     fertilizer
        # and we decide that we want to apply    (9...15) -> (20...26)
        #
        # then we want our new hash to look like
        #
        #  seed       fertilizer
        # (12...15) -> (23...26)
        # (15...19) -> (15...19)
        #
        # In other words… we want to cut ranges with other ranges?
        #
        #
        # that's to say, the new src rng always reduces the size of the current dst ranges

        src_rng = src_rng_start ... (src_rng_start + rng_len)
        dst_rng = dst_rng_start ... (dst_rng_start + rng_len)
        
        puts("\n  ## mapping #{src_rng} to #{dst_rng}")

        # we want to cut a piece of src_rng out of each existing dst_rng        
        range_map.values.each do |range_to_cut|
        
          # [ front ][ intersection ][ back ]
          #

          # for front and back, we place those ranges back in the range map verbatim (like we did for seeds initially)

          # for the "piece of the cake" that we cut out, set the values as the "adjusted range"

          result = range_remap(range_to_cut, src_rng, dst_rng)
          # puts("### #{range_to_cut} -> #{result.inspect}")
          new_range_map.merge!(result)
        end

        puts("  - next map is now #{new_range_map}\n")
      end

      # Using range_map and parsed_range_map, we can build up new_range_map
      range_map = new_range_map
    end

    range_map.values.map(&:begin).min
  end
end

#####
##### BOILERPLATE
#####

def test(_part)
  runner = AoC.new File.read('example.txt').split("\n\n")

  runner.test_range_remap

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
    two = runner.two_brute
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
    runner = AoC.new File.read("input.txt").split("\n\n")
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  puts "\n\n--- Part #{n} solution" if n != nil
  if n == '1' || (run_both && n == '2')
    puts "Result 1: #{runner.one}"
  end
  if n == '2'
    puts "Result 2: #{runner.two_brute}"
  end
end

main
