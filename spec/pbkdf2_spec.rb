require File.dirname(__FILE__) + '/spec_helper.rb'

describe PBKDF2, "when initializing" do
  it "should raise an ArgumentError if an unrecognized parameter is passed" do
    lambda {PBKDF2.new(:foo=>1)}.should raise_error(ArgumentError)
  end

  it "should raise an ArgumentError if a password is not set" do
    lambda {PBKDF2.new(:salt=>"nacl", :iterations=>1000)}.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if a salt is not set" do
    lambda {PBKDF2.new(:password=>"s33krit", :iterations=>1000)}.should raise_error(ArgumentError)
  end
  
  it "should raise an ArgumentError if iterations is not set" do
    lambda {PBKDF2.new(:password=>"s33krit", :salt=>"nacl")}.should raise_error(ArgumentError)
  end
  
  it "should allow setting options in a block" do
    PBKDF2.new do |x|
      x.password = "s33krit"
      x.salt = "nacl"
      x.iterations = 1000
    end
  end
end

describe PBKDF2, "when configuring a hash function" do
  it "should default to SHA256" do
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000)
    p.hash_function.name.should == "SHA256"
  end

  it "should support at least SHA1, SHA512, and MD5" do 
    %w{SHA1 SHA512 MD5}.each do |alg|
      p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>alg)
      p.hash_function.name.should == alg
    end
  end

  it "should allow setting by symbols" do 
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>:sha512)
    p.hash_function.name.should == "SHA512"
  end

  it "should allow setting by strings" do 
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>"sha512")
    p.hash_function.name.should == "SHA512"
  end

  it "should allow setting by PKCS-style 'hmacWith' strings" do 
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>"hmacWithSHA512")
    p.hash_function.name.should == "SHA512"
  end

  it "should allow setting by classes in OpenSSL::Digest" do 
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>OpenSSL::Digest::SHA512)
    p.hash_function.name.should == "SHA512"
  end

  it "should allow setting by an instantiated object of type OpenSSL::Digest::Digest" do 
    hfunc = OpenSSL::Digest::SHA512.new
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>hfunc)
    p.hash_function.name.should == "SHA512"
  end
end

describe PBKDF2, "when setting a key length" do
  it "should default to the size of the hash function used" do
    %w{SHA1 SHA512 MD5}.each do |alg|
      p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :hash_function=>alg)
      p.key_length.should == OpenSSL::Digest::Digest.new(alg).size
    end    
  end

  it "should throw an ArgumentError if a negative length is set" do
    lambda {p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1000, :key_length=>-1)}.should  raise_error(ArgumentError)
  end

  it "should throw an ArgumentError if too long a length is set" do
    not_too_long = ((2**32 - 1) * OpenSSL::Digest::SHA256.new.size)
    too_long = not_too_long + 1
    lambda {p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1, :key_length=>not_too_long, :hash_function=>:sha256)}.should_not  raise_error(ArgumentError)
    lambda {p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1, :key_length=>too_long, :hash_function=>:sha256)}.should  raise_error(ArgumentError)
  end

  it "should ensure that the derived key really is that long" do
    length = 123
    p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>1, :key_length=>length)
    p.bin_string.length.should == length
  end
end

describe PBKDF2, "when setting the number of iterations" do
  it "should throw an ArgumentError if a number less than 1 is passed" do
    lambda {p = PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>0)}.should  raise_error(ArgumentError)
  end
end

describe PBKDF2, "once created" do
  before do
    @p = PBKDF2.new do |x|
      x.password = "s33krit"
      x.salt = "nacl"
      x.iterations = 1
    end
    @val = @p.hex_string
  end

  it "should have the same hex value as another, identically derived key" do
    q = PBKDF2.new do |x|
      x.password = "s33krit"
      x.salt = "nacl"
      x.iterations = 1
    end
    @p.hex_string.should == q.hex_string
  end
  
  it "should recalculate the value if the password changes" do
    @p.password = "foo"
    @p.hex_string.should_not == @val
  end
  
  it "should recalculate the value if the salt changes" do
    @p.salt = "foo"
    @p.hex_string.should_not == @val
  end
  
  it "should recalculate the value if the number of iterations changes" do
    @p.iterations = 2
    @p.hex_string.should_not == @val
  end

  it "should recalculate the value if the hash function changes" do
    @p.hash_function = :md5
    @p.hex_string.should_not == @val
  end

  it "should recalculate the value if the key length changes" do
    @p.key_length = 10
    @p.hex_string.should_not == @val
  end
end