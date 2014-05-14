require "base_x/version"

class BaseX
  class InvalidNumeral < RuntimeError
    def initialize(invalid_char)
      super "Can't convert to integer, '#{invalid_char}' is not in the numeral list for this base"
    end
  end

  class EmptyString < RuntimeError
    def initialize
      super "Can't convert empty string into integer"
    end
  end

  EXAMPLE_TOKEN = "\xFC\x8E\x3C\x91\x7D\x58\x36\x8B" # Random 64-bit token

  def self.string_to_integer(string, opts)
    opts[:numerals].respond_to?(:index) or
      raise ArgumentError.new("A string of numerals must be provided, e.g. BaseX.string_to_integer(\"bcde\", numerals: \"abcdefg\")")
    new(opts[:numerals]).string_to_integer(string)
  end

  def self.integer_to_string(int, opts)
    opts[:numerals].respond_to?(:index) or
      raise ArgumentError.new("A string of numerals must be provided, e.g. BaseX.integer_to_string(123, numerals: \"abcdefg\")")
    new(opts[:numerals]).integer_to_string(int)
  end

  def self.encode(string, opts)
    opts[:numerals].respond_to?(:index) or
      raise ArgumentError.new("A string of numerals must be provided, e.g. BaseX.encode(\"Hello World\", numerals: \"abcdefg\")")
    new(opts[:numerals]).encode(string)
  end

  def self.decode(encoded, opts)
    opts[:numerals].respond_to?(:index) or
      raise ArgumentError.new("A string of numerals must be provided, e.g. BaseX.encode(\"bcaffag\", numerals: \"abcdefg\")")
    new(opts[:numerals]).decode(encoded)
  end

  def self.base(n)
    n.between?(2, 62) or raise ArgumentError.new("Base #{n} is not valid; base must be at least 2 and at most 62")
    digits_uppercase_lowercase = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    new(digits_uppercase_lowercase[0...n])
  end

  # Outputs an array of [base name, base size, example, and numerals] for all built-in bases
  def self.bases
    constants
      .map     { |const_name| [const_name, const_get(const_name)] }
      .select  { |const_name, base| base.is_a?(BaseX) }
      .sort_by { |const_name, base| [base.base, const_name.to_s] }
      .map do |const_name, base|
        [const_name.to_s, base.base, base.encode(EXAMPLE_TOKEN), base.numerals]
      end
  end

  def self.bases_table
    bases.map do |name, base_size, example, numerals|
      example = example[0...21] + "…" if example.size > 22
      [
        name,
        base_size,
        example.inspect.include?("\\")  ? example.inspect  : example,
        numerals.inspect.include?("\\") ? numerals.inspect : numerals,
      ]
    end.map do |array|
      "%-15s %-3s %-22s %s" % array
    end.join("\n")
  end

  def self.print_bases
    puts bases_table
  end

  attr_reader :numerals
  attr_reader :base

  def initialize(numerals)
    numerals.chars.size > 1 or
      raise ArgumentError.new("Need at least two numerals to express numbers! Numeral given: #{numerals.inspect}") 
    numerals.chars.size == numerals.chars.uniq.size or
      raise ArgumentError.new("Duplicate characters found in numerals definition: #{numerals.inspect}") 
    @numerals = numerals
    @base     = numerals.size
  end

  def string_to_integer(string)
    raise EmptyString.new unless string.size > 0
    integer = 0
    string.each_char do |char|
      integer *= base
      numeral_value = @numerals.index(char) or raise InvalidNumeral.new(char)
      integer += numeral_value
    end
    integer
  end

  def integer_to_string(int)
    return @numerals[0] if int == 0
    string = ""
    while int > 0
      char = @numerals[int % base]
      string << char
      int /= base
    end
    string.reverse
  end

  def encode(string)
    return "" if string.size == 0
    int = string.each_byte.reduce(0) { |int, byte| int *= 256; int + byte }
    encoded = integer_to_string(int)
    string_number_size = 256**(string.size)
    encoded_number_size = base**(encoded.size)

    while encoded_number_size < string_number_size
      encoded = @numerals[0] + encoded
      encoded_number_size *= base
    end

    encoded
  end

  def decode(encoded)
    return "" if encoded.size == 0
    int = string_to_integer(encoded)
    decoded = Base256.integer_to_string(int)
    decoded_number_size = 256**(decoded.size)
    encoded_number_size = base**(encoded.size)

    # encoded_number_size / base < decoded_number_size <= encoded_number_size
    while decoded_number_size <= encoded_number_size / base
      decoded = "\x00" + decoded
      decoded_number_size *= 256
    end

    decoded
  end
end

digits    = ("0".."9").to_a
uppercase = ("A".."Z").to_a
lowercase = ("a".."z").to_a

# Binary
BaseX::Binary     = BaseX.new("01")

# Base 16
BaseX::Base16L     = BaseX.new((digits + %w[a b c d e f]).join)
BaseX::Base16U     = BaseX.new((digits + %w[A B C D E F]).join)
BaseX::Base16      = BaseX::Base16L
BaseX::Hex         = BaseX::Base16
BaseX::Hexadecimal = BaseX::Base16

# Base 30, in case the number could change case
# no "u" following Crockford's probabilistic fear of accidental obscenity
# (I caluclate the probability of obscenity, with "u", is about 1 in 2^13
# for any given random 3-letter string (about 1 in 8000); when encoding 128bit
# tokens, after generating about 225 random tokens you have a 50% chance of
# having produced an "obscene token".)
BaseX::Base30L = BaseX.new((digits + lowercase - %w[0 1 i l o u]).join)
BaseX::Base30U = BaseX.new((digits + uppercase - %w[0 1 I L O U]).join)

# Base 31, in case the number could change case
BaseX::Base31L = BaseX.new((digits + lowercase - %w[0 1 i l o]).join)
BaseX::Base31U = BaseX.new((digits + uppercase - %w[0 1 I L O]).join)

# Base 32 schemes
BaseX::RFC4648Base32   = BaseX.new((uppercase + digits - %w[0 1 8 9]).join)
BaseX::CrockfordBase32 = BaseX.new((digits + uppercase - %w[I L O U]).join)

# Base58 schemes
BaseX::BitcoinBase58 = BaseX.new((digits + uppercase + lowercase - %w[0 O I l]).join)
BaseX::FlickrBase58  = BaseX.new((digits + lowercase + uppercase - %w[0 O I l]).join)
BaseX::GMPBase58     = BaseX.new((digits + uppercase + lowercase - %w[w x y z]).join)
BaseX::Base58        = BaseX::BitcoinBase58

# NewBase60, has an underscore as per http://tantek.pbworks.com/w/page/19402946/NewBase60
BaseX::NewBase60 = BaseX.new((digits + uppercase + %w[_] + lowercase - %w[O I l]).join)

# Base62; digits, upper, lower
BaseX::Base62DUL = BaseX.new((digits + uppercase + lowercase).join)
BaseX::Base62DLU = BaseX.new((digits + lowercase + uppercase).join)
BaseX::Base62LDU = BaseX.new((lowercase + digits + uppercase).join)
BaseX::Base62LUD = BaseX.new((lowercase + uppercase + digits).join)
BaseX::Base62UDL = BaseX.new((uppercase + digits + lowercase).join)
BaseX::Base62ULD = BaseX.new((uppercase + lowercase + digits).join)
BaseX::Base62    = BaseX::Base62DUL

# URL Base 64
BaseX::URLBase64 = BaseX.new((uppercase + lowercase + digits + %w[- _]).join)

# ZeroMQ Base 85
# Process your data back and forth between 4-byte and 5-byte chunks and you'll be compatible with the Z85 standard
BaseX::Z85 = BaseX.new((digits + lowercase + uppercase + %w|. - : + = ^ ! / * ? & < > ( ) [ ] { } @ % $ #|).join)

# Binary string encoding; turn binary strings into Bignums and back
BaseX::Base256 = BaseX.new((0..255).map(&:chr).join)

