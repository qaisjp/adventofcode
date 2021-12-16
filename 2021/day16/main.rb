# frozen_string_literal: true
# typed: true

# require 'OpenStruct'

class TrueClass; def to_i; 1; end; end
class FalseClass; def to_i; 0; end; end
class OutOfBits < Exception; end

class Array
  def ensure_size(n)
    raise "Expected #{self.inspect} to be size #{n}, got size #{size}" unless size == n
    self
  end
end

class BitStream
  def initialize(data)
    @bits = data
    @size = data.size
    @pos = 0

    @version_sum = 0
  end

  attr_reader :version_sum

  def read_bits(bits)
    if (@pos + bits) > @size
      raise OutOfBits.new("Tried requesting #{bits} bits but we're at pos #{@pos}, and size is #{@size}, so #{@pos + bits} is out of bounds.")
    end
    result = @bits[@pos...(@pos+bits)]
    @pos += bits
    result.join
  end

  def read_int(bits)
    read_bits(bits).to_i(2)
  end

  def read_bool
    read_bits(1) == "1"
  end

  # without header
  def read_literal_value_packet
    bits = []
    loop do
      continue = read_bool
      bits << read_bits(4)
      # puts "Reading bits for literal packet: #{bits.inspect}"
      break unless continue
    end
    bits.join
  end

  # without header
  def read_operator_packet
    length_type_id = read_bool
    if length_type_id
      subpacket_count = read_int(11)
    else
      body_size = read_int(15)
    end


    if body_size
      packets = []
      # keep reading packets until we've moved body_size bits
      bits_read = 0
      while bits_read < body_size
        current_pos = @pos
        packets << read_packet
        bits_read += @pos - current_pos
      end
      return packets
    end

    if subpacket_count # this is always true
      return subpacket_count.times.map do
        read_packet
      end
    end

    raise "Impossible"
  end

  def read_packet
    version = read_int(3)
    type_id = read_int(3)

    @version_sum += version

    data = if type_id == 4
      data = read_literal_value_packet
      # puts "Literal value #{data.inspect} (int #{data.to_i(2)}) read."
      data.to_i(2)
    else
      nums = read_operator_packet.map {_1[2]}
      case type_id
      when 0
        nums.sum
      when 1
        nums.inject(&:*)
      when 2
        nums.min
      when 3
        nums.max
      when 5
        x, y = nums.ensure_size(2)
        (x > y).to_i
      when 6
        x, y = nums.ensure_size(2)
        (x < y).to_i
      when 7
        x, y = nums.ensure_size(2)
        (x == y).to_i
      else
        raise "Unknown type_id #{type_id}"
      end
    end

    [version, type_id, data]
  end
end

# AoC
class AoC
  def initialize(data)
    bits = data.chars.flat_map {_1.to_i(16).to_s(2).rjust(4, '0').chars}
    @input = BitStream.new(bits)
  end

  def one
    @input.read_packet
    @input.version_sum
  end

  def two
    version, type_id, data = @input.read_packet
    data
  end
end

def test(part)
  example_inputs1 = {
    "D2FE28" => 6,
    "38006F45291200" => 9,
    "EE00D40C823060" => 14,
    "8A004A801A8002F478" => 16,
    "620080001611562C8802118E34" => 12,
    "C0015000016115A2E0802F182340" => 23,
    "A0016C880162017C3686B18A3D4780" => 31,
  }

  passed = true
  example_inputs1.each do |(str, part1)|
    runner = AoC.new(str)

    puts "== Testing #{str}"
    one = runner.one
    this = part1
    if one != this
      puts "Example part 1 was #{one}, expected #{this}"
      passed = false
    else
      puts "Example part 1 passes (#{one})"
    end
  end

  raise "Part 1 tests did not pass" unless passed

  example_inputs2 = {
    "C200B40A82" => 3,
    "04005AC33890" => 54,
    "880086C3E88112" => 7,
    "CE00C43D881120" => 9,
    "D8005AC2A8F0" => 1,
    "F600BC2D8F" => 0,
    "9C005AC2F8F0" => 0,
    "9C0141080250320F1802104A08" => 1,
  }

  example_inputs2.each do |(str, part2)|
    runner = AoC.new(str)

    puts "== Testing #{str}"
    two = runner.two
    this = part2
    if two != this
      puts "Example part 2 was #{two}, expected #{this}"
      passed = false
    else
      puts "Example part 2 passes (#{this})"
    end
  end

  # passed
  true
end

def main
  run_both = false

  n = ARGV.shift
  if ARGV.empty?
    runner = AoC.new File.read("input.txt").strip
  else
    runner = AoC.new ARGF.readlines.to_a
  end

  if !test(n)
    puts "Tests failed :("
    return
  end

  puts "\n\n--- Part #{n} solution" if n != ""
  if n == '1' || (run_both && n == '2')
    puts "Part 1 Result: #{runner.one}"
  end
  if n == '2'
    puts "Part 2 Result: #{runner.two}"
  end
end

main
