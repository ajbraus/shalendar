module Phony

  EMPTY_STRING = ''

  # Handles determining the correct national code handler.
  #
  class CountryCodes

    attr_reader   :splitter_mapping
    attr_accessor :international_absolute_format, :international_relative_format, :national_format

    def initialize
      @international_absolute_format = '+%s%s%s'
      @international_relative_format = '00%s%s%s'
      @national_format               = '%s%s'

      @normalize_format = '%s%s'
      @default_space    = ' '
    end

    def self.instance
      @instance ||= new
    end

    @@basic_normalizing_pattern = /^0+|\D/
    def clean number
      clean! number && number.dup
    end
    def clean! number
      # Remove non-digit chars.
      #
      number.gsub!(@@basic_normalizing_pattern, EMPTY_STRING) || number
    end
    def normalize number
      clean! number
      national_handler, cc, rest = split_cc number
      @normalize_format % [cc, national_handler.normalize(rest)]
    end

    # Splits this number into cc, ndc and locally split number parts.
    #
    def split number
      country_handler, cc, rest = split_cc number
      [cc, *country_handler.split(rest)]
    end

    def formatted number, options = {}
      format_cc_ndc_local options[:format], options[:spaces] || @default_space, *split(number)
    end
    # Formats country code and national destination code.
    #
    def format_cc_ndc_local format, space, cc, zero, ndc, *parts
      cc_ndc = format_cc_ndc format, space, cc, zero, ndc
      local  = if parts.empty?
                 cc_ndc = cc_ndc.slice 0...cc_ndc.rindex(space.to_s)
                 EMPTY_STRING
               else
                 format_local(space, parts) unless parts.empty?
               end
      cc_ndc.empty?? local : "#{cc_ndc}#{space}#{local}"
    end
    #
    # TODO This method needs an overhaul.
    #
    def format_cc_ndc format, space, cc, zero, ndc
      case format
      when nil, :international_absolute, :international, :+
        ndc ?
          @international_absolute_format % [cc, space, ndc] :
          @international_absolute_format % [cc, nil, nil]
      when :international_relative
        ndc ?
          @international_relative_format % [cc, space, ndc] :
          @international_relative_format % [cc, nil, nil]
      when :national
        ndc && !ndc.empty? ?
          @national_format % [zero, ndc] :
          @national_format % [zero, nil]
      when :local
        EMPTY_STRING
      end
    end
    def format_local space, parts_ary
      parts_ary.compact!
      parts_ary.join space.to_s
    end

    #
    #
    def service? number
      country_handler, cc, rest = split_cc number
      country_handler.service? rest
    end
    def mobile? number
      country_handler, cc, rest = split_cc number
      country_handler.mobile? rest
    end
    def landline? number
      country_handler, cc, rest = split_cc number
      country_handler.landline? rest
    end

    # Is the given number a vanity number?
    #
    def vanity? number
      country_handler, _, rest = split_cc number
      country_handler.vanity? rest
    end
    # Converts a vanity number into a normalized E164 number.
    #
    def vanity_to_number vanity_number
      country_handler, cc, rest = split_cc vanity_number
      "#{cc}#{country_handler.vanity_to_number(rest)}"
    end

    def split_cc rest
      presumed_cc = ''
      1.upto(3) do |i|
        presumed_cc << rest.slice!(0..0)
        country_handler = splitter_mapping[i][presumed_cc]
        return [country_handler, presumed_cc, rest] if country_handler
      end
      # This line is never reached as CCs are in prefix code.
    end

    # # TODO
    # #
    # def self.with_cc cc
    #   mapping[cc.size][cc.to_s]
    # end

    # Add the given country to the mapping under the
    # given country code.
    #
    def add country_code, country
      country_code = country_code.to_s
      optimized_country_code_access = country_code.size

      @splitter_mapping ||= {}
      @splitter_mapping[optimized_country_code_access] ||= {}
      @splitter_mapping[optimized_country_code_access][country_code] = country
    end

  end

end
