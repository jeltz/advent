m = [] of Array(Char)
File.each_line(ARGV[0]) do |l|
  m << l.chars
end
h, w = m.size, m[0].size

t = 0
loop do
  t += 1
  c = 0
  n = (0...h).map { ['.'] * w }

  (0...h).each do |i|
    (0...w).each do |j|
      if m[i][j] == '>' && m[i][(j + 1) % w] == '.'
        n[i][(j + 1) % w] = '>'
        c += 1
      elsif m[i][j] == '>' || m[i][j] == 'v'
        n[i][j] = m[i][j]
      end
    end
  end

  m = n
  n = (0...h).map { ['.'] * w }

  (0...h).each do |i|
    (0...w).each do |j|
      if m[i][j] == 'v' && m[(i + 1) % h][j] == '.'
        n[(i + 1) % h][j] = 'v'
        c += 1
      elsif m[i][j] == '>' || m[i][j] == 'v'
        n[i][j] = m[i][j]
      end
    end
  end

  break if c == 0

  m = n
end
puts t
