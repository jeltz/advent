File.open(ARGV[0]) do |f|
  f.read_line =~ /^Player 1 starting position: (\d+)$/
  ap = $1.to_i
  f.read_line =~ /^Player 2 starting position: (\d+)$/
  bp = $1.to_i
  d = 1
  a, b = 0, 0
  r = 0
  loop do
    3.times do
      ap = (ap + d - 1) % 10 + 1
      d = (d + 1) % 100
      r += 1
    end
    a += ap
    break if a >= 1000
    3.times do
      bp = (bp + d - 1) % 10 + 1
      d = (d + 1) % 100
      r += 1
    end
    b += bp
    break if b >= 1000
  end
  puts [a, b].min * r
end
