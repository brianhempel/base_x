require 'bundler/setup'
Bundler.require(:test)

require 'base_n'
require 'minitest/autorun'
require 'minitest/reporters'
MiniTest::Reporters.use! Minitest::Reporters::DefaultReporter.new

class TestBaseN < Minitest::Test
  def setup
    @base_n = BaseN.new("012")
  end

  attr_reader :base_n


  ### Instance Methods ###


  def test_complains_if_numerals_has_duplicate_chars
    BaseN.new("∫©¶çΩ≈") # no error
    assert_raises(ArgumentError) { BaseN.new("∫©¶çΩ≈Ω") }
  end

  def test_complains_if_only_one_numeral
    BaseN.new("∫©") # no error
    assert_raises(ArgumentError) { BaseN.new("")  }
    assert_raises(ArgumentError) { BaseN.new("∫") }
  end

  def test_string_to_integer
    assert_equal 48, base_n.string_to_integer("01210")
  end

  def test_string_to_integer_errors_with_invalid_chars
    assert_raises(BaseN::InvalidNumeral) do
      base_n.string_to_integer("asdf")
    end
  end

  def test_string_to_integer_errors_with_empty_string
    assert_raises(BaseN::EmptyString) do
      base_n.string_to_integer("")
    end
  end

  def test_integer_to_string
    assert_equal "1210", base_n.integer_to_string(48)
  end

  def test_0_to_string
    assert_equal "0", base_n.integer_to_string(0)
  end

  def test_encode_decode_empty_string
    assert_equal "", base_n.decode(base_n.encode(""))
  end

  def test_encode_decode_zeros
    assert_equal "\x00\x00\x00\x00", base_n.decode(base_n.encode("\x00\x00\x00\x00"))
  end

  def test_encode_decode_stuff
    assert_equal "stuff", base_n.decode(base_n.encode("stuff"))
  end

  def test_a_bunch_of_zero_strings_in_a_bunch_of_bases
    (2..10).each do |base|
      base_n = BaseN.new(('a'..'z').take(base).join)
      (1..257).to_a.sample(20).each do |size|
        assert_equal "\x00"*size, base_n.decode(base_n.encode("\x00"*size)), "problem with #{size} length zero string in base #{base}"
      end
    end
  end

  def test_a_bunch_of_random_strings_in_a_bunch_of_bases
    (2..10).each do |base|
      base_n = BaseN.new(('a'..'z').take(base).join)
      (1..257).to_a.sample(20).each do |size|
        string = SecureRandom.random_bytes(size)
        assert_equal string.dup, base_n.decode(base_n.encode(string)), "problem encoding/decoding #{string.inspect} in base #{base}"
      end
    end
  end


  ### Class Methods ###


  def test_integer_to_string_class_method
    assert_equal "1210", BaseN.integer_to_string(48, numerals: "012")
  end

  def test_integer_to_string_claass_methods_complains_if_no_numerals_provided
    assert_raises(ArgumentError) { BaseN.integer_to_string(48, numerals: Object.new) }
  end

  def test_string_to_integer_class_method
    assert_equal 48, BaseN.string_to_integer("01210", numerals: "012")
  end

  def test_string_to_integer_claass_methods_complains_if_no_numerals_provided
    assert_raises(ArgumentError) { BaseN.string_to_integer("01210", numerals: Object.new) }
  end

  def test_encode_decode_class_methods
    assert_equal "stuff", BaseN.decode(BaseN.encode("stuff", numerals: "012"), numerals: "012")
  end

  def test_encode_class_method_complains_if_no_numerals_provided
    assert_raises(ArgumentError) { BaseN.encode("stuff", numerals: Object.new) }
  end

  def test_decode_class_method_complains_if_no_numerals_provided
    assert_raises(ArgumentError) { BaseN.decode("stuff", numerals: Object.new) }
  end

  def test_base_class_method
    assert_equal "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZab", BaseN.base(38).numerals
  end

  def test_base_class_method_errors
    BaseN.base(2)  # no error
    BaseN.base(62) # no error
    assert_raises(ArgumentError) { BaseN.base(1) }
    assert_raises(ArgumentError) { BaseN.base(63) }
  end

  def test_bases_class_method
    assert_equal ["Binary", 2, "1111110010001110001111001001000101111101010110000011011010001011", "01"], BaseN.bases.first
    expected_order = %w[
      Binary
      Base16
      Base16L
      Base16U
      Hex
      Hexadecimal
      Base30L
      Base30U
      Base31L
      Base31U
      CrockfordBase32
      RFC4648Base32
      Base58
      BitcoinBase58
      FlickrBase58
      GMPBase58
      NewBase60
      Base62
      Base62DLU
      Base62DUL
      Base62LDU
      Base62LUD
      Base62UDL
      Base62ULD
      URLBase64
      Z85
      Base256
    ]
    assert_equal expected_order, BaseN.bases.map(&:first)
  end

  def test_bases_table_class_method
    assert_equal String, BaseN.bases_table.class # it doesn't blow up
  end


  ### Base Constants ###


  def test_binary
    assert_equal "111010110111100110100010101",    BaseN::Binary.integer_to_string(123456789)
    assert_equal "111010110111100110100010110001", BaseN::Binary.integer_to_string(987654321)
  end

  def test_base16L
    assert_equal "75bcd15",  BaseN::Base16L.integer_to_string(123456789)
    assert_equal "3ade68b1", BaseN::Base16L.integer_to_string(987654321)
  end

  def test_base16U
    assert_equal "75BCD15",  BaseN::Base16U.integer_to_string(123456789)
    assert_equal "3ADE68B1", BaseN::Base16U.integer_to_string(987654321)
  end

  def test_base30L
    assert_equal "74eg8b",  BaseN::Base30L.integer_to_string(123456789)
    assert_equal "3cnbspq", BaseN::Base30L.integer_to_string(987654321)
  end
    
  def test_base30U
    assert_equal "74EG8B",  BaseN::Base30U.integer_to_string(123456789)
    assert_equal "3CNBSPQ", BaseN::Base30U.integer_to_string(987654321)
  end

  def test_base31L
    assert_equal "6bq524",  BaseN::Base31L.integer_to_string(123456789)
    assert_equal "35hft2u", BaseN::Base31L.integer_to_string(987654321)
  end

  def test_base31U
    assert_equal "6BQ524",  BaseN::Base31U.integer_to_string(123456789)
    assert_equal "35HFT2U", BaseN::Base31U.integer_to_string(987654321)
  end

  def test_rfc4648_base32
    assert_equal "DVXTIV", BaseN::RFC4648Base32.integer_to_string(123456789)
    assert_equal "5N42FR", BaseN::RFC4648Base32.integer_to_string(987654321)
  end

  def test_crockford_base32
    assert_equal "3NQK8N", BaseN::CrockfordBase32.integer_to_string(123456789)
    assert_equal "XDWT5H", BaseN::CrockfordBase32.integer_to_string(987654321)
  end

  def test_bitcoin_base58
    assert_equal "BukQL",  BaseN::BitcoinBase58.integer_to_string(123456789)
    assert_equal "2WGzDn", BaseN::BitcoinBase58.integer_to_string(987654321)
  end

  def test_flickr_base58
    assert_equal "bUKpk",  BaseN::FlickrBase58.integer_to_string(123456789)
    assert_equal "2vgZdM", BaseN::FlickrBase58.integer_to_string(987654321)
  end

  def test_gmp_base58
    assert_equal "AqhNJ",  BaseN::GMPBase58.integer_to_string(123456789)
    assert_equal "1TFvCj", BaseN::GMPBase58.integer_to_string(987654321)
  end

  def test_new_base60
    assert_equal "9XZZ9",  BaseN::NewBase60.integer_to_string(123456789)
    assert_equal "1GCURM", BaseN::NewBase60.integer_to_string(987654321)
  end

  def test_base62_dul
    assert_equal "8M0kX",  BaseN::Base62DUL.integer_to_string(123456789)
    assert_equal "14q60P", BaseN::Base62DUL.integer_to_string(987654321)
  end

  def test_base62_dlu
    assert_equal "8m0Kx",  BaseN::Base62DLU.integer_to_string(123456789)
    assert_equal "14Q60p", BaseN::Base62DLU.integer_to_string(987654321)
  end

  def test_base62_ldu
    assert_equal "iwaK7",  BaseN::Base62LDU.integer_to_string(123456789)
    assert_equal "beQgaz", BaseN::Base62LDU.integer_to_string(987654321)
  end

  def test_base62_lud
    assert_equal "iwaUH",  BaseN::Base62LUD.integer_to_string(123456789)
    assert_equal "be0gaz", BaseN::Base62LUD.integer_to_string(987654321)
  end

  def test_base62_udl
    assert_equal "IWAk7",  BaseN::Base62UDL.integer_to_string(123456789)
    assert_equal "BEqGAZ", BaseN::Base62UDL.integer_to_string(987654321)
  end

  def test_base62_uld
    assert_equal "IWAuh",  BaseN::Base62ULD.integer_to_string(123456789)
    assert_equal "BE0GAZ", BaseN::Base62ULD.integer_to_string(987654321)
  end

  def test_url_base64
    assert_equal "HW80V", BaseN::URLBase64.integer_to_string(123456789)
    assert_equal "63mix", BaseN::URLBase64.integer_to_string(987654321)
  end

  def test_z85
    assert_equal "2v2B/", BaseN::Z85.integer_to_string(123456789)
    assert_equal "i]jLP", BaseN::Z85.integer_to_string(987654321)
  end

  def test_base256
    assert_equal "\x07\x5B\xCD\x15".force_encoding("ASCII-8BIT"), BaseN::Base256.integer_to_string(123456789)
    assert_equal "\x3A\xDE\x68\xB1".force_encoding("ASCII-8BIT"), BaseN::Base256.integer_to_string(987654321)
  end
end
