require 'openssl'

class PBKDF2
  VERSION = '0.2.2'

  def initialize(opts = {})
    @hash_function = OpenSSL::Digest.new('sha256')

    # override with options
    opts.each_key do |k|
      if self.respond_to?("#{k}=")
        send("#{k}=", opts[k])
      else
        fail ArgumentError, "Argument '#{k}' is not allowed"
      end
    end

    yield self if block_given?

    # set this to the default if nothing was given
    @key_length ||= @hash_function.size

    # make sure the relevant things got set
    fail ArgumentError, 'password not set' if @password.nil?
    fail ArgumentError, 'salt not set' if @salt.nil?
    fail ArgumentError, 'iterations not set' if @iterations.nil?
  end
  attr_reader :key_length, :hash_function, :iterations, :salt, :password

  def key_length=(l)
    fail ArgumentError, 'key too short' if l < 1
    fail ArgumentError, 'key too long' if l > ((2**32 - 1) * @hash_function.size)
    @value = nil
    @key_length = l
  end

  def hash_function=(h)
    @value = nil
    @hash_function = find_hash(h)
  end

  def iterations=(i)
    fail ArgumentError, "iterations can't be less than 1" if i < 1
    @value = nil
    @iterations = i
  end

  def salt=(s)
    @value = nil
    @salt = s
  end

  def password=(p)
    @value = nil
    @password = p
  end

  def value
    calculate! if @value.nil?
    @value
  end

  alias_method :bin_string, :value

  def hex_string
    bin_string.unpack('H*').first
  end

  # return number of milliseconds it takes to complete one iteration
  def benchmark(iters = 400_000)
    iter_orig = @iterations
    @iterations = iters
    start = Time.now
    calculate!
    time = Time.now - start
    @iterations = iter_orig
    (time / iters)
  end

  protected

  # finds and instantiates, if necessary, a hash function
  def find_hash(hash)
    case hash
    when Class
      # allow people to pass in classes to be instantiated
      # (eg, pass in OpenSSL::Digest::SHA1)
      hash = find_hash(hash.new)
    when Symbol
      # convert symbols to strings and see if OpenSSL::Digest can make sense of
      hash = find_hash(hash.to_s)
    when String
      # if it's a string, first strip off any leading 'hmacWith' (which is implied)
      hash.gsub!(/^hmacWith/i, '')
      # see if the OpenSSL lib understands it
      hash = OpenSSL::Digest.new(hash)
    when OpenSSL::Digest
    when OpenSSL::Digest::Digest
      # ok
    else
      fail TypeError, "Unknown hash type: #{hash.class}"
    end
    hash
  end

  # the pseudo-random function defined in the spec
  def prf(data)
    OpenSSL::HMAC.digest(@hash_function, @password, data)
  end

  # this is a translation of the helper function "F" defined in the spec
  def calculate_block(block_num)
    # u_1:
    u = prf(salt + [block_num].pack('N'))
    ret = u
    # u_2 through u_c:
    2.upto(@iterations) do
      # calculate u_n
      u = prf(u)
      # xor it with the previous results
      ret = ret ^ u
    end
    ret
  end

  # the bit that actually does the calculating
  def calculate!
    # how many blocks we'll need to calculate (the last may be truncated)
    blocks_needed = (@key_length.to_f / @hash_function.size).ceil
    # reset
    @value = ''
    # main block-calculating loop:
    1.upto(blocks_needed) do |block_num|
      @value << calculate_block(block_num)
    end
    # truncate to desired length:
    @value = @value.slice(0, @key_length)
    @value
  end
end

String.class_eval do
  def ^(other)
    unless other.is_a? String
      fail ArgumentError, "Can't bitwise-XOR a String with a non-String"
    end

    unless length == other.length
      fail ArgumentError, "Can't bitwise-XOR strings of different length"
    end

    xor_impl(other)
  end

  private

  def xor_impl(other)
    each_byte.with_index.map do |b, i|
      other.getbyte(i) ^ b
    end.pack('C*')
  end
end
