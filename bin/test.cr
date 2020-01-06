require "../src/cache_hash"

def test1
  puts "Testing fetch"
  c = CacheHash(Symbol, String).new(ttl: 3, gc_interval: 1)

  c[:a] = "its here"

  sleep 1
  puts c.fetch(:a, "its gone!")

  sleep 1
  puts c.fetch(:a, "its gone!")

  sleep 1
  puts c.fetch(:a, "its gone!")

  sleep 1
  puts c.fetch(:a, "its gone!")

  sleep 1
  puts c.fetch(:a, "its gone!")
end

def test2
  puts "Testing array syntax"
  c = CacheHash(Symbol, String).new(ttl: 3, gc_interval: 1)

  c[:a] = "its here"

  sleep 1
  puts c[:a] || "its gone!"

  sleep 1
  puts c[:a] || "its gone!"

  sleep 1
  puts c[:a] || "its gone!"

  sleep 1
  puts c[:a] || "its gone!"

  sleep 1
  puts c[:a] || "its gone!"

  sleep 1
  puts c[:a] || "its gone!"

  sleep 1
  puts c[:a] || "its gone!"
end

def test3
  puts "Testing block"
  c = CacheHash(Symbol, Int32).new(ttl: 3, gc_interval: 1)

  x = 0
  10.times do
    r = c.fetch(:foo) {
      puts "expired cache"
      x
    }
    x = x + 1
    puts r
    sleep 2
  end
end

def test4
  puts "Testing default"
  c = CacheHash(Symbol, String).new(ttl: 2, gc_interval: 1)

  x = 0
  c[:foo] = "HAZ VALUE"
  4.times do
    r = c.fetch(:foo, "NO VALUE")
    x = x + 1
    puts r
    sleep 1
  end
end

test2
test1
test3
test4
