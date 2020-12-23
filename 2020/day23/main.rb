# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @label = T.let(data[0].chars.map(&:to_i), T::Array[Integer])
  end
  
  def get(n)
    size = @label.size
    @label[size % n]
  end

  def one
    100.times do |move_id|
      puts "-- move #{move_id+1} --"
      current = @label.first

      puts "cups: (#{current}) #{@label.join(" ")}"
      a, b, c = @label.delete_at(1), @label.delete_at(1), @label.delete_at(1)
      puts "pick up #{a}, #{b}, #{c}"

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

      puts "destination: #{@label[found_index]}"
      found_index += 1
      @label.insert(found_index, c)
      @label.insert(found_index, b)
      @label.insert(found_index, a)

      @label.rotate!
      puts
    end
    
    while @label[0] != 1
      @label.rotate!
    end
    @label[1..].join("")
  end

  def two
    max = @label.max
    ((max+1)..1000000).each do |n|
      @label << n
    end
    puts @label.last
    puts "appended"

    10000000.times do |move_id|
      # puts "-- move #{move_id+1} --"
      current = @label.first

      # puts "cups: (#{current}) #{@label.join(" ")}"
      a, b, c = @label.delete_at(1), @label.delete_at(1), @label.delete_at(1)
      # puts "pick up #{a}, #{b}, #{c}"

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

      # puts "destination: #{@label[found_index]}"
      found_index += 1
      @label.insert(found_index, c)
      @label.insert(found_index, b)
      @label.insert(found_index, a)

      @label.rotate!
      # puts
    end
    
    i = @label.find_index(1)
    [get(i+1), get(i+2)]
  end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    puts "Result: #{runner.one}"
  elsif n == '2'
    puts "Result: #{runner.two}"
  end
end
main
