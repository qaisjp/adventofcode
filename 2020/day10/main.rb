# frozen_string_literal: true
# typed: true

require 'set'
require 'sorbet-runtime'

# AoC
class AoC
  def initialize(data)
    @bag_jolts = data.map(&:to_i)

    @device_jolt = @bag_jolts.max + 3
    @outlet_jolt = 0

    @available_jolts = T.let(@bag_jolts.dup, T::Array[Integer])
    @available_jolts << @device_jolt
    raise unless @available_jolts.to_set.size == @available_jolts.size
  end

  def one
    differences = {}

    available_jolts = @available_jolts.dup

    current_jolt = @outlet_jolt
    while current_jolt < @device_jolt
      jolt_found = false
      [1, 2, 3].each do |difference|
        try_jolt = current_jolt + difference
        if available_jolts.include? try_jolt
          jolt_found = true
          available_jolts.delete(try_jolt)

          differences[difference] ||= 0
          differences[difference] += 1

          current_jolt = try_jolt
          break
        end
      end

      puts "NF - current: #{current_jolt}, available: #{available_jolts}" unless jolt_found
    end

    puts "#{differences} becomes #{differences[1] * differences[3]}"

  end

  def two_naive(base_jolt: @outlet_jolt, max_jolt: @device_jolt)
    pending_jolts = T::Set[T::Array[Integer]].new [
      [base_jolt],
    ]

    # completed_sequences = T::Set[T::Array[Integer]].new []
    completed_sequences = 0

    while !pending_jolts.empty?
      # puts "Pending jolts now #{pending_jolts.size}"
      pending_jolts.dup.each do |jolt_sequence|
        current_jolt = T.must(jolt_sequence.last)

        [1, 2, 3].each do |difference|
          try_jolt = current_jolt + difference
          if @available_jolts.include? try_jolt
            if try_jolt == max_jolt
              # completed_sequences << new_jolt_sequence
              completed_sequences += 1
            else
              new_jolt_sequence = jolt_sequence.dup
              new_jolt_sequence << try_jolt
              pending_jolts << new_jolt_sequence
            end
          end
        end

        # Remove the current sequence from the the pending jolts
        pending_jolts.delete(jolt_sequence)
      end
    end


    puts "Distinct arrangements: #{completed_sequences}"
    completed_sequences
  end

  def two_smart
    main_sequence = @available_jolts.sort
    main_sequence.insert(0, 0)

    subsequences = T::Array[T::Array[Integer]].new []

    prev = 0
    main_sequence.each_with_object([]) do |n, seq|
      if n - prev == 3
        puts "Found #{seq}"
        subsequences << seq.dup
        seq.clear
      end
      seq << n
      prev = n
    end
    puts "subs: #{subsequences}"
    result = subsequences.map {|a| a.size == 1 ? 1 : two_naive(base_jolt: a.first, max_jolt: a.last)}.inject(:*)
    puts "ans: #{result}"
  end

end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    runner.one
  elsif n == '2'
    runner.two_smart
  elsif n == '3'
    runner.two_naive
  end
end
main
