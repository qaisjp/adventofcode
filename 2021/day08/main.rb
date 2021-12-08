# frozen_string_literal: true
# typed: true

# AoC


class String
  def -(other)
    (self.chars - other.chars).sort.join
  end

  def normal
    self.chars.uniq.sort.join
  end

  def *(other)
    (self + other).normal
  end

  def first
    self.chars.first
  end

  def last
    self.chars.last
  end

  def is_size(x)
    raise "string #{self} should be size #{x}, got #{size}" if size != x
    self
  end
end

class AoC

  @@strs = [
    "abcefg",
    "cf",
    "acdeg",
    "acdfg",
    "bcdf",
    "abdfg",
    "abdefg",
    "acf",
    "abcdefg",
    "abcdfg",
  ]

  @@str_to_digit = @@strs.map {[_1, @@strs.index(_1)]}.to_h
  @@size_to_digit = @@strs.group_by {_1.size}.filter {_2.size == 1}.map {|size, v| [size, @@str_to_digit[v.first]]}.to_h
  @@digit_to_size = @@strs.each_with_index.map {|str, i| [i, str.size]}.to_h

  def initialize(data)
    # @data = data.map(&:to_i)
    @data = data.map do |line|
      input, output = line.split("|").map {_1.strip}
      [input.split, output.split]
    end
  end

  def one
    count = 0
    @data.each do |line|
      input, output = line
      # puts "output: #{output}"
      this_count = output.count do
        size = _1.size
        # puts "size of #{_1} is #{size}"
        @@size_to_digit[size] != nil
      end
      # puts "count: #{this_count}"
      count += this_count
    end

    count
  end

  def size_for(digit)
    @@digit_to_size[digit]
  end

  def figure_line(input)
    input = input.map(&:normal).uniq
    sizes = input.map(&:size)
    size_to_strs = input.group_by {_1.size}

    one = size_to_strs[size_for(1)].first
    four = size_to_strs[size_for(4)].first
    seven = size_to_strs[size_for(7)].first
    eight = size_to_strs[size_for(8)].first

    a = (seven - one).is_size(1)      # one value
    c = (one).is_size(2)              # two values (shared with f)
    f = (one).is_size(2)              # two values (shared with c)
    b = (four - seven).is_size(2)     # two values (shared with d)
    d = (four - seven).is_size(2)     # two values (shared with b)
    e = (eight - four - a).is_size(2) # two values (shared with g)
    g = (eight - four - a).is_size(2) # two values (shared with e)

    # Lets try to build a 9
    nine_without_tail = a * four

    # puts "One is #{one} Four is #{four} Nine without tail is #{nine_without_tail}"
    # puts "Potential nine: #{g.first * nine_without_tail}"
    # puts "Potential nine: #{g.last * nine_without_tail}"
    if input.include?(g.first * nine_without_tail)
      e = g.last
      g = g.first
    elsif input.include?(g.last * nine_without_tail)
      e = g.first
      g = g.last
    else
      raise "nine not in input #{input}"
    end

    # sitrep
    a = a
    e = e
    g = g

    # Lets try to build a 3
    three_without_d = a * one * g
    if input.include?(d.first * three_without_d)
      b = d.last
      d = d.first
    elsif input.include?(d.last * three_without_d)
      b = d.first
      d = d.last
    else
      raise "three not in input #{input}"
    end

    # sitrep
    a = a
    b = b
    # c
    d = d
    e = e
    # f
    g = g

    # Lets try to build a 6
    six_without_f = a * b * d * e * g
    if input.include?(f.first * six_without_f)
      c = f.last
      f = f.first
    elsif input.include?(f.last * six_without_f)
      c = f.first
      f = f.last
    else
      raise "six not in input #{input}"
    end

    options = {
      "a" => a,
      "b" => b,
      "c" => c,
      "d" => d,
      "e" => e,
      "f" => f,
      "g" => g,
    }.invert

    raise "not complete" unless options.values.map(&:size).all? {|x| x == 1}
    options
  end 

  def convert(map, str)
    new_str = str.chars.map { |c| map[c] }.sort.join
    # puts "New str is #{new_str}"
    @@str_to_digit[new_str]
  end

  def two
    sum = 0
    @data.each do |line|
      input, output = line

      known_digits = (input.map {_1.size}.uniq & @@size_to_digit.keys).sort
      puts "Line #{line} does not know all keys, it knows sizes #{known_digits}, wanted #{@@size_to_digit.keys.sort}" if @@size_to_digit.keys.sort != known_digits
      maps = figure_line(input + output)
      sum += output.map {|str| convert(maps, str)}.map(&:to_s).join.to_i
    end

    sum
  end
end

$examples = [
  26,
  61229,
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
