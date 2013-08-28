module Screp
  module GeneralUtilities
    def check_options(options, *valid_keys)
      options.keys.each do |k|
        raise ArgumentError, "Option '#{k}' not supported" if !valid_keys.include? k.to_sym
      end
    end
  end
end
