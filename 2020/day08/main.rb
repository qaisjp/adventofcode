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

  def inspect
    "Instr(#{op.serialize}, #{arg})"
  end

  def to_s
    inspect
  end
end

Instructions = T.type_alias {T::Array[Instruction]}

class ProgramExecutor
  extend T::Sig

  attr_reader :acc
  attr_reader :pc

  def reset!
    @acc = 0
    @pc = 0
  end

  sig {params(instrs: Instructions).void}
  def initialize(instrs)
    @instrs = T.let(instrs.dup, Instructions)
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
    puts "Execution completed. Acc is #{@acc}"
  end
end

class AoC
  extend T::Sig

  def initialize(data)
    instrs = data.map do |line|
      op, arg = line.scanf("%s %d")
      Instruction.new(op: Op.deserialize(op), arg: arg)
    end
    @instructions = T.let(instrs, Instructions)
  end

  def one
    exec = ProgramExecutor.new(@instructions)
    seen_instructions = T.let(Set.new, T::Set[Integer])
    before_exec = lambda do |pc, instr|
      if seen_instructions.include?(pc)
        puts "Running ##{pc} a second time. Accumulator is #{exec.acc}"
        return false
      end
      seen_instructions << pc
      true
    end
    exec.run!(before_exec: before_exec)
  end

  sig {params(instrs: Instructions, i: Integer).returns(Instructions)}
  def swap_param(instrs, i)
    instrs = instrs.dup
    instr = instrs.fetch(i).dup
    if instr.op == Op::JMP
      instr.op = Op::NOP
    elsif instr.op == Op::NOP
      instr.op = Op::JMP
    end
    instrs[i] = instr
    instrs
  end

  def two;
      index_to_modify = 0
      max_index = @instructions.size
      while index_to_modify < max_index
        new_instructions = swap_param(@instructions, index_to_modify)
        exec = ProgramExecutor.new(new_instructions)

        success = T.let(true, T::Boolean)
        seen_instructions = T.let(Set.new, T::Set[Integer])
        before_exec = lambda do |pc, instr|
          if seen_instructions.include?(pc)
            puts "Running ##{pc} a second time. Accumulator is #{exec.acc}"
            success = false
            return false
          end
          seen_instructions << pc
          true
        end
        exec.run!(before_exec: before_exec)

        break if success
        index_to_modify += 1
      end
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
