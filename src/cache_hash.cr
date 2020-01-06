class CacheHash(K, V)
  class Box(T)
    getter :value, :expires_at

    @expires_at : Time::Span

    def initialize(value : T, ttl : Int = 10)
      @value = value
      @expires_at = Time.monotonic + Time::Span.new(seconds: ttl, nanoseconds: 0)
    end

    def initialize(value : T, ttl : Time::Span)
      @value = value
      @expires_at = Time.monotonic + ttl
    end
  end

  # CacheHash is a simple hash implementation where the
  # value is purged after TTL seconds.

  getter :ttl, :gc_interval

  # Creates CacheHash and starts garbage collection
  # @param [seconds] ttl Number to seconds to retain value
  # @param [seconds] gc_interval Seconds to wait between GC
  def initialize(ttl = 60, gc_interval = 10)
    @data = Hash(K, Box(V)).new
    @mutex = Mutex.new

    @ttl = Time::Span.new(seconds: ttl, nanoseconds: 0)
    @gc_interval = gc_interval # seconds
    start_gc
  end

  # Sets a value for a key and returns the value
  # @param [Object] key
  # @param [Object] value
  # @return [Object] value
  def []=(key, value)
    @mutex.synchronize {
      @data[key] = Box(V).new(
        value: value,
        ttl: @ttl,
      )
    }
    value
  end

  # Gets value for key, or nil if expired
  # @param [Object] key
  # @return [Object, nil]
  def [](key)
    @mutex.synchronize {
      if @data.has_key?(key)
        if Time.monotonic > @data[key].expires_at
          # @data.delete(key)
          return nil
        else
          return @data[key].value
        end
      end
    }
    return nil
  end

  # Gets value for key, or default_value if expired
  # @param [Object] key
  # @param [Object] default_value
  # @param [Block]
  # @return [Object, nil]
  def fetch(key, default_value : V)
    self[key] || default_value
  end

  def fetch(key, &)
    self[key] = yield
  end

  # Kick off garbage collection in a thread
  def start_gc
    spawn do
      loop do
        sleep @gc_interval
        gc
      end
    end
  end

  # Delete keys with expired values
  def gc
    now = Time.monotonic
    @mutex.synchronize {
      @data.each do |key, value|
        if now > @data[key].expires_at
          @data.delete key
        end
      end
    }
  end
end
