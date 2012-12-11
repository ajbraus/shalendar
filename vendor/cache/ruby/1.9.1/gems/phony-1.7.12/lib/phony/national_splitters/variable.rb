module Phony
  
  module NationalSplitters
    
    class Variable < Fixed
      
      #
      #
      def initialize fallback, ndcs, options = {}
        super fallback, options
        @ndcs = optimize ndcs
      end
      
      # Takes a national number and splits it into ndc and rest.
      #
      def split national_number
        fallback_number = national_number.dup
        
        # Extract a starting point.
        #
        presumed_code = if @mapped_ndc_min_length > 0
          national_number.slice!(0..@mapped_ndc_min_length-1)
        else
          ''
        end
        
        # Try for all possible mapped.
        #
        @mapped_ndc_min_length.upto(@mapped_ndc_max_length) do |i|
          sized_ndcs = @ndcs[i]
          return [@zero, presumed_code, national_number] unless sized_ndcs && !sized_ndcs.include?(presumed_code)
          presumed_code << national_number.slice!(0..0)
        end
        
        # Not found.
        #
        super fallback_number
      end
      
      private
        
        # def restructure ndc_map
        #   optimize ndc_map.values.flatten
        # end
        
        # Optimizes and restructures the given ndcs array.
        #
        def optimize(ndc_ary)
          ndcs = {}
          ndc_ary.each do |ndc|
            ndcs[ndc.length] ||= []
            ndcs[ndc.length] << ndc
          end
          keys = ndcs.keys
          @mapped_ndc_min_length = keys.min # || 1
          @mapped_ndc_max_length = keys.max
          ndcs
        end
      
    end
    
  end
  
end