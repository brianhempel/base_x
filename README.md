# BaseN

BaseN is a arbitrary base conversion library that, in addition to converting to/from integers, also supports encoding and decoding arbitrary binary data into and out of any base.

Many known bases are included, such as [Bitcoin Base58](https://en.bitcoin.it/wiki/Base58Check_encoding).

BaseN is useful for generating human-friendly cryptographic tokens and ID's, and could even be usde for encoding, transmitting, and decoding binary data over binary-unsafe mediums.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'base_n'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install base_n
```

## Usage

Let's convert some numbers.

```ruby
# Emulate hex, just for fun.
BaseN.integer_to_string(241,  numerals: "0123456789abcdef")
# => "f1"
BaseN.string_to_integer("f1", numerals: "0123456789abcdef")
# => 241

# Bitcoin Base58 numerals. No O, 0, I, or l
BaseN.integer_to_string(456724510, numerals: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
# => "hMqHX"
BaseN.string_to_integer("hMqHX",   numerals: "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz")
# => 456724510

# That was rather clumsy, so let's use the provided Base58 object
BaseN::Base58.integer_to_string(456724510)
# => "hMqHX"
```

If you use a base more than once, make it a constant.

```ruby
Base24Greek = BaseN.new("αβγδεζηθικλμνξοπρστυφχψω")

Base24Greek.integer_to_string(456724510)
# => "ιψια"
Base24Greek.string_to_integer("ιψια")
# => 456724510
```

## Encoding

Use the `encode` and `decode` methods to convert arbitary binary data to and from the desired base.

```ruby
BaseN::Base30L.encode("Hello World!")
# => "3xtzc85paptyrbdjgd27"
BaseN::Base30L.decode("3xtzc85paptyrbdjgd27")
# => "Hello World!"

BaseN.encode("SOS", numerals: "01")
# => "010100110100111101010011"
BaseN.decode("010100110100111101010011", numerals: "01")
# => "SOS"
```

The encoding scheme is simple: BaseN treats the whole binary blob as one large big-endian binary number and then converts that number into the desired base. If the original binary had leading 0 bytes, leading "0"'s are added to the converted number.

```ruby
Base10 = BaseN.new("0123456789")

Base10.encode("Hi")         # => "18537"
Base10.encode("\x00Hi")     # => "00018537"
Base10.encode("\x00\x00Hi") # => "0000018537"
```

## Token Generation

BaseN is great for generating tokens for identification or cryptographic purposes.

```ruby
require 'securerandom'

bytes = SecureRandom.random_bytes(16) # 128 bits

BaseN::Base30L.encode(bytes)
# => "347wbrazxkvj59atq5zh2fdk55e"
BaseN::Base58.encode(bytes)
# => "SLrA71VABcvExTht6KLr89"
```

## Provided Bases

BaseN provides some bases you can use right away.

| Constant(s)                                                        | Example (64-bit token)   | Numerals            | Numerals added/omitted     | Origin                                                             |
|--------------------------------------------------------------------|--------------------------|---------------------|----------------------------|--------------------------------------------------------------------|
| `BaseN::Binary`                                                    | `111111001000111000111…` | 0-1                 |                            | Binary!                                                            |
| `BaseN::Base16` `BaseN::Base16L` `BaseN::Hex` `BaseN::Hexadecimal` | `fc8e3c917d58368b`       | 0-9a-f              |                            | Lowercase [hexadecimal](http://en.wikipedia.org/wiki/Hexadecimal). |
| `BaseN::Base16U`                                                   | `FC8E3C917D58368B`       | 0-9A-F              |                            | Uppercase [hexadecimal](http://en.wikipedia.org/wiki/Hexadecimal). |
| `BaseN::Base30L`                                                   | `369be5e68tfqth`         | 2-9a-hj-km-np-tv-z  | `0 1 i l o u` omitted      | A BaseN special. All characters that could be confused in uppercase or lowercase are removed, so it is suitable for case-insensitive tokens. See `BaseN::CrockfordBase32` for why "u" is removed. |
| `BaseN::Base30U`                                                   | `369BE5E68TFQTH`         | 2-9A-HJ-KM-NP-TV-Z  | `0 1 I L O U` omitted      | Uppercase version of above. I think lowercase is easier to read. |
| `BaseN::Base31L`                                                   | `s59ez2tk5bep7`          | 0-9a-hj-km-np-z     | `0 1 i l o` omitted        | A BaseN special. All characters that could be confused in uppercase or lowercase are removed, so it is suitable for case-insensitive tokens. The "u" is retained. |
| `BaseN::Base31U`                                                   | `S59EZ2TK5BEP7`          | 0-9A-HJ-KM-NP-Z     | `0 1 I L O` omitted        | Uppercase version of above. I think lowercase is easier to read. |
| `BaseN::RFC4648Base32`                                             | `PZDR4SF6VQNUL`          | A-Z2-7              | `0 1 8 9` omitted          | The base 32 numerals of [RFC 4648](http://tools.ietf.org/html/rfc4648#page-8). |
| `BaseN::CrockfordBase32`                                           | `FS3HWJ5YNGDMB`          | 0-9A-HJ-KM-NP-TV-Z  | `I L O U` omitted          | The numerals of Douglas Crockford's [Base32 proposal](http://www.crockford.com/wrmg/base32.html). Crockford fears that allowing "u" may result in "accidental obscenity". What's the actually probability of a problem? I calculate that, with "u" as a possible numeral, a random 3-numeral string has about a 1/8000 chance of phonetically dropping the f-bomb on a viewer; a 128-bit token encoded in base32 has 26 numerals and thus 24 3-numeral strings, consequently about 1 in every 340 such tokens would be vulgar. |
| `BaseN::Base58` `BaseN::BitcoinBase58`                             | `jF78uMwAKKg`            | 1-9A-HJ-NP-Za-km-z  | `0 I O l` omitted          | The numeral scheme used in [Bitcoin addresses](https://en.bitcoin.it/wiki/Base58Check_encoding). |
| `BaseN::FlickrBase58`                                              | `Jf78UmWajjF`            | 1-9a-km-zA-HJ-NP-Z  | `0 I O l` omitted          | The numeral scheme in [Flickr short URLs](https://www.flickr.com/groups/api/discuss/72157616713786392/). Same as Bitcoin, but lowercase preceeds uppercase. |
| `BaseN::GMPBase58`                                                 | `gE67qKs9IId`            | 0-9A-Za-v           | `w x y z` omitted          | The numeral scheme used for [base conversions in the GMP arbitary-precision math library](https://gmplib.org/manual/Converting-Integers.html). |
| `BaseN::NewBase60`                                                 | `W5pTz7hmhxF`            | 0-9A-HJ-NP-Z_a-km-z | `I O l` omitted, `_` added | A [scheme by Tantek Çelik](http://tantek.pbworks.com/w/page/19402946/NewBase60), originally for use in a URL shortener. The "_" still allows the whole text to be selected when double-clicking. |
| `BaseN::Base62` `BaseN::Base62DUL`                                 | `LgLY9aNSIf5`            | 0-9A-Za-z           |                            | All alphanumeric characters: digits then uppercase then lowercase. |
| `BaseN::Base62DLU`                                                 | `lGly9AnsiF5`            | 0-9a-zA-Z           |                            | All alphanumeric characters: digits then lowercase then uppercase. |
| `BaseN::Base62LDU`                                                 | `vGv8jAx2sFf`            | a-z0-9A-Z           |                            | All alphanumeric characters: lowercase then digits then uppercase. |
| `BaseN::Base62LUD`                                                 | `vQvIjKxCsPf`            | a-zA-Z0-9           |                            | All alphanumeric characters: lowercase then uppercase then digits. |
| `BaseN::Base62UDL`                                                 | `VgV8JaX2SfF`            | A-Z0-9a-z           |                            | All alphanumeric characters: uppercase then digits then lowercase. |
| `BaseN::Base62ULD`                                                 | `VqViJkXcSpF`            | A-Za-z0-9           |                            | All alphanumeric characters: uppercase then lowercase then digits. |
| `BaseN::URLBase64`                                                 | `PyOPJF9WDaL`            | A-Za-z0-9-_         | `- _` added                | Alphanumerics plus `-` and `_`. Intended as a base 64 that can be used in URLs; part of [RFC 4648](http://tools.ietf.org/html/rfc4648#page-7). I find URL base 64 annoying because double-clicking won't select through the `-`. |
| `BaseN::Z85`                                                       | `]MO]Dt%j>*`             | 0-9a-zA-Z.-:+=^!/*?&<>()[]{}@%$# | `. - : + = ^ ! / * ? & < > ( ) [ ] { } @ % $ #` added | The base 85 numerals used for [ZeroMQ Z85](http://rfc.zeromq.org/spec:32), an encoding standard optimized for 4-byte words and for pasting into single-quoted strings. |
| `BaseN::Base256`                                                   | `\xFC\x8E<\x91}X6\x8B`   | `"\x00"`-`"\xFF"`   |                            | Byte 0 through byte 255; useful for convert binary strings into a number and back. Used internally by BaseN. |

Note that although the number schemes from various standards are represented here, BaseN is a number converter only: it does not do padding or other standard-specific details. BaseN is not, for example, a Z85 compliant encoder/decoder. You could, however, easily build one with BaseN.

In Ruby, you can uses `BaseN.bases` and `BaseN.print_bases` to get information similar to the above table.

```
> BaseN.print_bases
Binary          2   111111001000111000111… 01
Base16          16  fc8e3c917d58368b       0123456789abcdef
Base16L         16  fc8e3c917d58368b       0123456789abcdef
Base16U         16  FC8E3C917D58368B       0123456789ABCDEF
Hex             16  fc8e3c917d58368b       0123456789abcdef
Hexadecimal     16  fc8e3c917d58368b       0123456789abcdef
Base30L         30  369be5e68tfqth         23456789abcdefghjkmnpqrstvwxyz
...
```

### BaseN.base(n)

In addition to the named constants above, you can also quickly generate any alphanumeric base between 2 and 62. This could be handy becuase Ruby's `to_i` and `to_s` methods only support bases 2 to 36.

```ruby
BaseN.base(49).integer_to_string(456724510)
# => "1UB4UI"
BaseN.base(49).string_to_integer("1UB4UI")
# => 456724510

# The order of numerals is digits then uppercase then lowercase
BaseN.base(49).numerals
# => "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklm"
```

## Use Base30L

If you want your text to be transferred by any means other than copy-paste, I recommend `BaseN::Base30L`. Tokens have a bad habit of landing in places where they cannot be copied and pasted. Anecdotal evidence from my recent past:

- There was an infographic that had cited URLs baked into the image. I wanted to check the sources but could not copy the URLs, so I had to retype them. Also, some of the URLs had "O"'s in them.
- I recently transferred a shared secret from one computer to another "off the wire". I had my mother read the secret out loud from the other computer. Happily, the secret did not have mixed case: saying "capital L, lowercase u" would have doubled the tedium.

You can't predict what people are going to do with your encoded text, so it makes sense to be prepared.

## Edge Cases

Even though `"".to_i` is `0` in Ruby, BaseN's `string_to_integer` will reject empty strings with a `BaseN::EmptyString` error. An empty string here is probably a bug in your code. (In contrast, the `encode` and `decode` functions do accept empty strings.)

If you try to convert a string that uses a character not in the base, a `BaseN::InvalidNumeral` error will be raised.

## Limitations

If you try to encode/decode in a numeral system larger than base 256 (why would you do this?!), leading 0 bytes may not be properly preserved. Integer conversion will still work as expected.

## License

Public Domain; no rights reserved.

No restrictions are placed on the use of BaseN. That freedom also means, of course, that no warrenty of fitness is claimed; use BaseN at your own risk.

Public domain dedication is explained by the CC0 1.0 summary (and only the summary) at https://creativecommons.org/publicdomain/zero/1.0/

## Contributing

1. Fork it ( http://github.com/brianhempel/base_n/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Run the tests with either `guard` or `minitest`
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push -u origin my-new-feature`)
6. Create a new Pull Request
