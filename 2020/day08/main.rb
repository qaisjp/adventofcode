# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'scanf'
require 'set'

# AoC
class AoC
  class Op < T::Enum
    enums do
      NOP = new('nop')
      ACC = new('acc')
      JMP = new('jmp')
    end
  end
  class Instruction < T::Struct
    prop :op, Op
    prop :arg, Integer
  end

  def reset!
    @acc = 0
    @pc = 0
  end

  def initialize(data)
    reset!
    instrs = data.map do |line|
      op, arg = line.scanf("%s %d")
      Instruction.new(op: Op.deserialize(op), arg: arg)
    end
    @instructions = T.let(instrs, T::Array[Instruction])
  end

  def one
    seen_instructions = Set.new
    loop do
      instr = @instructions[@pc]
      if !instr
        puts "Missing instruction for pc #{@pc}"
        break
      end

      if seen_instructions.include?(@pc)
        puts "Running ##{@pc} a second time. Accumulator is #{@acc}"
        break
      end
      seen_instructions << @pc

      next_pc = @pc + 1
      op = instr.op
      case op
      when Op::ACC
        @acc += instr.arg
      when Op::JMP
        next_pc = @pc + instr.arg
      when Op::NOP
        # do nothing
      else
        T.absurd(op)
      end

      @pc = next_pc
    end
  end

  def two; end
end

def main
  n = ARGV.shift
  runner = AoC.new ARGF.readlines.to_a

  if n == '1'
    runner.one
  else
    runner.two
  end
end
main
