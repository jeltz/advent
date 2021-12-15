def f(m, v, small, n)
  return 1 if n == "end"
  if ('a'..'z').includes?(n[0])
    return 0 if v[n] && (small || n == "start")
    small = n if v[n]
    v[n] = true
  end
  s = m[n].map do |t|
    f(m, v, small, t)
  end.sum
  v[n] = false unless n == small
  s
end

m = Hash(String, Array(String)).new
File.each_line(ARGV[0]) do |l|
  a, b = l.split(/-/)
  (m[a] ||= [] of String) << b
  (m[b] ||= [] of String) << a
end

puts f(m, Hash(String, Bool).new(false), nil, "start")
