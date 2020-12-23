# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  attr_accessor :label

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @label = T.let(data[0].chars.map(&:to_i), T::Array[Integer])
  end
  
  def get(n)
    @label[@size % n]
  end

  def run(move_id, print)
    puts "-- move #{move_id+1} --" if print || move_id % 200 == 0
    current = @label.first

    puts "cups: #{@label.join(" ").gsub(current.to_s, "(#{current})")}" if print
    a, b, c = @label.delete_at(1), @label.delete_at(1), @label.delete_at(1)
    puts "pick up #{a}, #{b}, #{c}" if print

    needle = current-1
    minval = @label.min
    found_index = nil
    while !found_index do
      found_index = @label.find_index(needle)
      break if found_index

      needle -= 1
      if needle < minval
        needle = @label.max
      end
    end

    puts "destination: #{@label[found_index]}" if print
    found_index += 1
    @label.insert(found_index, c)
    @label.insert(found_index, b)
    @label.insert(found_index, a)

    @label << @label.shift
    puts if print
  end

  def one(pr, n: 100)
    puts 'One called'
    setup!
    n.times do |move_id|
      run(move_id, pr)
    end
    
    while @label[0] != 1
      @label.rotate!
    end
    @label[1..].join("")
  end

  def setup!
    print 'setup... '
    @size = @label.size
    print 'size, '
    @indices = {}
    @label.each_with_index do |n, i|
      @indices[n] = i
    end
    print 'indices, '
    puts 'done'
  end

  def test!
    old = @label.dup
    result = one(false)
    @label = old.dup
    raise unless result == '62934785' || one(false) == '67384529'
    @label = old
    puts 'One passed'
  end

  def two
    test!

    max = @label.max
    ((max+1)..1000000).each do |n|
      @label << n
    end
    print @label.last
    puts " appended"

    setup!
    
    10000000.times do |move_id|
      run(move_id, false)
    end
    
    i = @label.find_index(1)
    [get(i+1), get(i+2)]
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '0'
    old = runner.label.dup
    result = runner.one(true, n: 10)
    runner.label = old
    puts "\n\ntests"
    runner.test!
    raise unless result == '92658374'
  elsif n == '1'
    puts "Result: #{runner.one(true)}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
