require 'thread'

class Promise < BasicObject
  def initialize(&block)
    @block = block
    @m = ::Mutex.new
  end

  if ::ENV['RUBINIUS_FIX']
    def __class__
      ::STDERR.puts "*** Promise#__class__ invoked!"
      ::Promise
    end
  end

  def __force__
    @m.synchronize do
      @block.call
    end
  end

  def _dump(limit)
    ::Marshal.dump(__force__, limit)
  end

  def self._load(o)
    ::Marshal.load(o)
  end

  def respond_to?(method, include_all=false)
    return false if :marshal_dump.equal?(method)

    :_dump.equal?(method) ||  # for Marshal
      :force.equal?(method) ||
      :__force__.equal?(method) ||
      __force__.respond_to?(method, include_all)
  end

  def method_missing(method, *args, &block)
    __force__.__send__(method, *args, &block)
  end
end
