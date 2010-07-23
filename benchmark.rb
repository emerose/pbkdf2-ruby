require 'benchmark'
require 'lib/pbkdf2'

n = 5000
#
# from active-ldap
module Salt
  CHARS = ['.', '/', '0'..'9', 'A'..'Z', 'a'..'z'].collect do |x|
    x.to_a
  end.flatten
  module_function
  def generate(length)
    salt = ""
    length.times {salt << CHARS[rand(CHARS.length)]}
    salt
  end
end

def next_salt
  Salt.generate(64)
end
Benchmark.bm do |x|
  x.report do
    1.upto(n) do
      PBKDF2.new do |p| 
        p.password = "s33krit"
        p.salt = next_salt
        p.iterations = 10000
      end
    end
  end
end

