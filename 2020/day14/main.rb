# frozen_string_literal: true

require 'sorbet-runtime'
require 'ostruct'
require 'scanf'


# AoC
class AoC
  Assign = Struct.new(:addr, :val)

  def initialize(data)
    # @data = T.let(data.map(&:to_i), T::Array[Integer])
    @data = data

    @mem = {}
    @combis = []
  end

  def one

    mask = ""
    or_mask = 0
    and_mask = 0

    @data.each do |line|
      if line.start_with? "mask = "
        mask = T.let(line.split("= ")[1], String)
        or_mask = mask.gsub("X", "0").to_i(base=2)
        and_mask = mask.gsub("X", "1").to_i(base=2)
        next
      end
      addr, val = line.scanf("mem[%d] = %d")
      new_val = val
      new_val |= or_mask
      new_val &= and_mask
      @mem[addr] = new_val
    end

    @mem.reject {|x| x.nil?}.sum

    # @assigns.each
  end

  def get_addrs(addr, mask_indices, index_to_vals)
    index_to_vals.map do |bit_vals|
      m = addr.dup
      mask_indices.each_with_index do |str_index, i|
        m[str_index] = bit_vals[i].to_s
      end
      m
    end
  end

  def two

    mask = ""
    or_mask = 0
    random_bit_indices = []
    index_to_vals = []

    @data.each do |line|
      if line.start_with? "mask = "
        mask = T.let(line.split("= ")[1], String)
        or_mask = mask.gsub("X", "0").to_i(base=2)
        random_bit_indices = mask.enum_for(:scan, /(?=X)/).map { Regexp.last_match.offset(0).first }
        index_to_vals = [1, 0].repeated_permutation(random_bit_indices.size).to_a
        next
      end

      addr, val = line.scanf("mem[%d] = %d")
      addr |= or_mask
      get_addrs(addr.to_s(base=2).rjust(36, '0'), random_bit_indices, index_to_vals).each do |mod_addr|
        @mem[mod_addr.to_i(base=2)] = val
      end

    end

    @mem.values.sum

    # @assigns.each
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
