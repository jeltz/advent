def f(m, v, n)
  return 1 if n == "end"
  return 0 if v[n]
  v[n] = true if ('a'..'z').includes?(n[0])
  s = m[n].map do |t|
    f(m, v, t)
  end.sum
  v[n] = false
  s
end

m = Hash(String, Array(String)).new
File.each_line(ARGV[0]) do |l|
  a, b = l.split(/-/)
  (m[a] ||= [] of String) << b
  (m[b] ||= [] of String) << a
end

puts f(m, Hash(String, Bool).new(false), "start")
