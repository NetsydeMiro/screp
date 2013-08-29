module Screp
  module GeneralUtilities

    def check_options(options, *valid_keys)
      options.keys.each do |k|
        raise ArgumentError, "Option '#{k}' not supported" if !valid_keys.include? k.to_sym
      end
    end


    def format_download(download)
      case download
      when String
        return {download => File.basename(download)}
      when Hash
        return download
      else
        raise ArgumentError, "Download must be specified as either a String or Hash"
      end
    end

  end
end
