# -*- coding: utf-8 -*- #

module Rouge
  module Lexers
    class Ada < RegexLexer
      tag 'ada'
      title "Ada"
      desc 'a programming language designed to support the construction of '\
           'long-lived, highly reliable software systems'
      filenames '*.ada', '*.adb', '*.ads'

      mimetypes 'text/x-ada', 'text/x-adasrc'

      keywords = %w(
        abort abs abstract accept access aliased all and array at begin body case
        constant declare delay delta digits do else elsif end entry exception exit for
        function generic goto if in interface is limited loop mod new not null of or
        others out overriding package pragma private procedure protected raise range
        record rem renames requeue return reverse select separate some subtype
        synchronized tagged task terminate then type until use when while with xor
      )

      # Types defined in package 'Standard'
      standard_types = %w(
        boolean integer float character wide_character wide_wide_character string
        wide_string wide_wide_string duration
      )

      id = /(?u)\w+/

      state :whitespace do
        rule /\s+/m, Text
        rule /--.*$/, Comment::Single
      end

      numeral = /[\d_]+/
      based_numeral = /[\d_A-F]+/i
      exponent = /E(\+|-)?#{numeral}/

      state :literal do
        rule /'[^']'/, Str::Char

	# " is escaped by doubling it
	rule /"([^"]|"")*"/i, Str::Single

	# Leading '-' is an operator, not part of the literal!
	# Based literals
	rule /#{numeral}\##{based_numeral}.#{based_numeral}\#(#{exponent})?/, Num::Float
	rule /#{numeral}\##{based_numeral}\#(#{exponent})?/, Num::Integer

	# Decimal literals
	rule /#{numeral}[.]#{numeral}(#{exponent})?/i, Num::Float
	rule /#{numeral}(#{exponent})?/, Num::Integer
      end

      state :attribute do
	rule /'#{id}/i, Name::Attribute
      end

      state :operator do
	rule %r{and then|and|or else|or|not|xor|abs|mod|rem|not in|in}, Operator::Word
	rule %r{/|&|/=|>=|>|<=|<|=|\*\*|\*|\+|-}, Operator
      end

      state :punctuation do
	rule /[().,:;]/, Punctuation
      end

      state :root do
        mixin :whitespace
	mixin :literal
	mixin :attribute
	mixin :operator
	mixin :punctuation

	rule /\b(#{keywords.join('|')})\b/i, Keyword
	rule /\b(#{standard_types.join('|')})\b/i, Keyword::Type

        rule id, Name
      end

    end
  end
end
