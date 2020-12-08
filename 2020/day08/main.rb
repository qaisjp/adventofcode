# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'scanf'
require 'set'

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

class ProgramExecutor
  extend T::Sig

  attr_reader :acc
  attr_reader :pc

  def reset!
    @acc = 0
    @pc = 0
  end

  sig {params(instrs: T::Array[Instruction]).void}
  def initialize(instrs)
    @instrs = T.let(instrs.dup, T::Array[Instruction])
    @acc = T.let(0, Integer)
    @pc = T.let(0, Integer)
  end

  sig {params(before_exec: T.nilable(T.proc.params(pc: Integer, instr: Instruction).returns(T::Boolean))).void}
  def run!(before_exec: nil)
    loop do
      instr = @instrs[@pc]
      if !instr
        puts "Missing instruction for pc #{@pc}"
        break
      end

      if !before_exec.nil?
        return unless before_exec.call(@pc, instr)
      end

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
end

class AoC
  def initialize(data)
    instrs = data.map do |line|
      op, arg = line.scanf("%s %d")
      Instruction.new(op: Op.deserialize(op), arg: arg)
    end
    @instructions = T.let(instrs, T::Array[Instruction])
    @seen_instructions = T.let(Set.new, T::Set[Integer])
  end

  def one
    exec = ProgramExecutor.new(@instructions)

    before_exec = lambda do |pc, instr|
      if @seen_instructions.include?(pc)
        puts "Running ##{pc} a second time. Accumulator is #{exec.acc}"
        return false
      end
      @seen_instructions << pc
      true
    end
    exec.run!(before_exec: before_exec)
  end
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
