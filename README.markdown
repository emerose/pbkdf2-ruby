# PBKDF2 #

A Ruby implementation of the [Password-Based Key-Derivation Function, uh,
2][PBKDF2].

## Using PBKDF2 ##

The basic steps are: 

1. Instantiate a `PBKDF2` object 
2. Call `#bin_string` (or `#hex_string`) on it to recover the binary (hex) form of the key

To instantiate, you can either pass the required arguments as options in a
hash, like so:

    PBKDF2.new(:password=>"s33krit", :salt=>"nacl", :iterations=>10000)

or use the (easier and prettier, in my view) builder idiom:

    PBKDF2.new do |p| 
      p.password = "s33krit"
      p.salt = "nacl"
      p.iterations = 10000
    end

You can also mix-and-match ways of passing arguments, but I don't know why
you'd want to do that.

### Required options ###

A `PBKDF2` object cannot be instantiated without setting the following options:

* **`password`**: The passphrase used for the key, passed as a (possibly
  binary) string.

  This should be kept secret, preferably nowhere but the end-user's memory.

* **`salt`**: A salt for this passphrase, passed as a (possibly binary)
  string.

  This does not need to be kept secret, but should be made as long as is
  reasonable (64-128 bits) to avoid precomputed image ("rainbow table")
  attacks.

* **`iterations`**: The number of iterated hashes to calculate, expressed as
  an integer.

  This does not need to be kept secret, but should be made as large as is
  reasonable.  See below for guidance on choosing a good number for this.

PBKDF2 objects can also be configured with the following options:

* **`hash_function`**: The hashing algorithm to be used.  

  This option may be expressed in a number of ways:
    * As a `Class` object, such as `OpenSSL::Digest::SHA512`. Only OpenSSL
      digest classes are supported at the moment.
    * As an already-instantiated OpenSSL digest object, such as the result of
      `OpenSSL::Digest::SHA512.new`. If you use this method, take care that
      the hash object is in its just-initialized state (or that the same hash
      object with the same state is used whenever keys are generated/checked).
    * As a string which is understood by `OpenSSL::Digest::Digest.new()`.  
      Things like "sha1", "md5", "RIPEMD160", etc. all work fine.  If the
      string begins with the text "hmacWith" it will be stripped before
      passing it to the underlying OpenSSL library, making it possible to use
      arguments that at least look more like the ASN.1 identifiers in the
      spec.
    * A symbol, like `:sha256`, that, when converted to a string, meets the
      rules for strings above.

  If not specified, SHA-256 will be used.  (Note that other implementations
  may default to SHA-1.)

* **`key_length`**: The length, in bytes, of the key you wish to generate.

  By default, the key generated will be equal in length to the hash output
  size. This can be adjusted to any size required, up to `((2**32 - 1) * (hash
  length)`.

If a required parameter is missing, or if an invalid parameter is passed to one of these options, an `ArgumentError` exception will be raised.

## Setting the Number of Iterations ##

The `iterations` option exposed by PBKDF2 provides a way of controlling the 
amount of work required to check a candidate passphrase.  It can be thought of
as a work factor governing the amount of work an attacker must do in order to
perform a dictionary or brute-force attack on passwords.  Unfortunately, it
also governs the amount of work that must be performed on behalf of legitimate
users must when checking credentials.

Choosing the correct value for this parameter is thus a balancing act: it
should be set as high as possible, to make attacks as difficult as possible,
without making legitimate applications unusably slow.  One method for choosing
a value is based on estimating an upper bound on the resources an attacker is
likely to have available, and then finding an iteration count that makes such
attacks unprofitable.  A useful example of this sort of reasoning can be found
in the [Security Considerations section of RFC 3962][ITERS].

The other approach for choosing the iterations count is to decide the maximum
performance penalty that can be tolerated in the context of the application,
and to set the iteration count so that it remains within these bounds.  The
`PBKDF2` module contains a `benchmark` method for this purpose: to use it,
instantiate a `PBKDF2` object as normal, using the `hash_function` and
`key_length` you intend to use in the final application.  Then, call the
`benchmark` method on the object: the result will be the time, in seconds,
required to complete one iteration.  Divide the maximum performance penalty
by this number to find the number of iterations you should choose.

The first method requires implementors to estimate a number of important
variables, including the resources available to attackers, which may be
difficult or impossible to do well.  The second method is also prone to error,
as it can be difficult to predict load characteristics in production
conditions, or the impact of a few milliseconds' delay on end-user
perceptions.  The best approach will necessarily involve trying both
approaches and balancing the competing concerns against one-another.

Note that no default for this option is provided, as a way of forcing 
implementors to consider this issue in their own contexts. Anyone who, having
read and understood the above, is still unsure what the value to choose should
just use 5,000 and move on.

## Relevant Standards ##

PBKDF2 was originally defined as part of RSA Laboratories' [PKCS #5][PKCS],
part of their Public-Key Cryptography Standards series. It has since been
republished as [RFC 2898][RFC].

### Standards Conformance ###

This implementation conforms to [RFC 2898][RFC], and has been tested using the
test vectors in Appendix B of [RFC 3962][3962]. Note, however, that while
those specifications use [HMAC][HMAC]-[SHA-1][SHA1], **this implementation
defaults to [HMAC][HMAC]-[SHA-256][SHA1]**. (SHA-256 provides a longer bit
length. In addition, NIST has [stated][NIST] that SHA-1 should be phased out
due to concerns over recent cryptanalytic attacks.)

## TODO ##

This version is essentially complete.  If ASN.1 weren't such a nightmare, it 
might be useful to be able to initialize `PBKDF2` objects based on standard
OIDs for parameters.  It would also be nice to have a standard envelope for 
serializing sets of {key, salt, options}.  Both of these are probably tasks
for other modules, however.  (YAML fits the bill pretty well already.)

## License ##

This software is ©2008 Sam Quigley <quigley@emerose.com>.  See the
LICENSE.TXT file accompanying this document for the terms under which it may
be used and distributed.

[PBKDF2]: http://en.wikipedia.org/wiki/PBKDF2 "Wikipedia: PBKDF2"
[PKCS]: http://www.rsa.com/rsalabs/node.asp?id=2127 "PKCS #5"
[RFC]: http://tools.ietf.org/html/rfc2898 "RFC 2898"
[3962]: http://tools.ietf.org/html/rfc3962 "RFC 3962"
[SHA1]: http://en.wikipedia.org/wiki/SHA-1 "Wikipedia: SHA-1"
[HMAC]: http://tools.ietf.org/html/rfc2104 "RFC 2104"
[ITERS]: http://tools.ietf.org/html/rfc3962#page-6 "RFC 3962: Section 8"
[NIST]: http://csrc.nist.gov/groups/ST/hash/statement.html "NIST Comments on Cryptanalytic Attacks on SHA-1"