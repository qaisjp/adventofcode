# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'

# AoC
class AoC
  extend T::Sig

  attr_accessor :label

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = data[0].chars.map(&:to_i)
  end

  def follow(key, n)
    those = []
    while n > 0
      key = @label[key]
      those << key
      n -= 1
    end
    those
  end

  def get_cups_str
    ns = []
    key = @current
    loop do
      ns << key
      key = @label[key]
      break if key == @current
    end
    ns.join(" ").gsub(@current.to_s, "(#{@current})")
  end

  def run(move_id, print)
    puts "-- move #{move_id+1} - #{Time.now - @start_time} --" if print || move_id % 200000 == 0

    puts "cups: #{get_cups_str}" if print
    a, b, c = follow(@current, 3)
    puts "pick up #{a}, #{b}, #{c}" if print

    # current - - -> label[c]
    @label[@current] = @label[c]
    @label.delete(a)
    @label.delete(b)
    @label.delete(c)

    needle = @current-1
    while !(c_to = @label[needle]) do
      needle -= 1
      if needle < @minval
        needle = @label.keys.max
      end
    end

    puts "destination: #{needle}" if print

    @label[needle] = a
    @label[a] = b
    @label[b] = c
    @label[c] = c_to

    @current = @label[@current]
    puts if print
  end

  def one(pr, n: 100)
    puts 'One called'
    setup!
    n.times do |move_id|
      run(move_id, pr)
    end

    label = []
    first = 1
    c = first
    while (c = @label[c]) != first
      label << c
    end
    label.join("")
  end

  def setup!
    @start_time = Time.now
    print 'setup... '

    label = @data.each_with_index.map do |n, i|
      [n, @data[i+1] || @data.first]
    end.to_h
    @label = T.let(label, T::Hash[Integer, Integer])
    @first = @data.first
    @current = @first
    @minval = @label.keys.min

    print 'label, '
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

    max = @data.max
    ((max+1)..1000000).each do |n|
      @data << n
    end
    puts " appended"

    setup!
    
    10000000.times do |move_id|
      run(move_id, false)
    end
    
    a = @label[1]
    b = @label[a]
    [a, b, a * b]
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
