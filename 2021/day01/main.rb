num = ARGV.shift
puts "q#{num}"
$stuff = ARGF.read.to_s.strip.split.map(&:to_i)

def stuff
    $stuff
end

def window_sum(i)
    thing = [stuff[i], stuff[i+1], stuff[i+2]]
    if thing != thing.compact
        return nil
    end
    thing.sum
end

def one
    count = 0
    stuff.each_with_index do |this, i|
        if i > 0
            if this > stuff[i-1]
                count += 1
            end
        end
    end
    puts count
end

def two
    sum = window_sum(0)
    count = 0
    (1...).each do |i|
        this_sum = window_sum(i)
        if this_sum.nil?
            puts count
            return
        end

        if this_sum > sum
            count += 1
        end
        sum = this_sum
    end
end

if num == "1"
    one
elsif num == "2"
    two
end
