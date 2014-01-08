require_relative 'text_utilities'
require_relative 'http_utilities'
require_relative 'general_utilities'

require 'csv'

module Screp

  class Screp
    include TextUtilities, HttpUtilities, GeneralUtilities

    # can take boolean value for option :silent
    # and IO options for options :out and :err
    def initialize(options = {})

      opts = {silent: false, out: $stdout, err: $stderr}.merge(options)

      @out, @err = if opts[:silent]
                     [StringIO.new, StringIO.new]
                   else
                     [opts[:out], opts[:err]]
                   end

      @url_stack = []
      @selection_stack = []
      @csv = []
      @downloads = []
    end

    attr_accessor :csv, :downloads

    ### PARSING ###

    def selected
      @selection_stack.last || @home_page
    end

    def url
      @url_stack.last || @home_url
    end

    def count(selector)
      selected.css(selector).count
    end

    def scrape(url, &block)
      @err.puts "\rParsing #{url}".ljust(80)[0..79]
      page = Nokogiri::HTML(open(url))

      # keep first page, in case we want to scrape or download 
      # with default log file name after the scrape block
      @home_url ||= url
      @home_page ||= page

      @url_stack.push url
      @selection_stack.push page
      instance_exec &block if block
      @selection_stack.pop 
      @url_stack.pop 
    end

    def each(*args, &block)
      selector, range = args
      range ||= (0..-1)
      range = (range..range) if range.class == Fixnum
      selected.css(selector)[range].each_with_index do |selected, index|
        @selection_stack.push selected
        instance_exec index, &block
        @selection_stack.pop 
      end
    end

    def first(selector, &block)

      if block
        each(selector, 0, &block)
      else
        selected.css(selector).first
      end
    end

    def last(selector, &block)
      if block
        each(selector, -1, &block)
      else
        selected.css(selector).last
      end
    end

    def method_missing(meth, *args, &block)
      if selected.respond_to? meth
        selected.send meth, *args, &block
      else
        super
      end
    end


    ### CSV LOGGING ###

    def log(*items)
      if items.length == 1 and items.first.class == Array
        # can log an array
        @csv << items.first
      else
        # or a bunch of arguments
        @csv << items
      end
    end

    def init_log(options = {})
      check_options(options, :filename, :headers)

      @csv_filename = options[:filename] || "#{filename_scrub(url)}.csv"
      @csv << options[:headers] if options[:headers]
    end

    def write_log

      if @csv.length > 0
        init_log if !@csv_filename

        CSV.open(@csv_filename, 'w') do |csv|
          @csv.each do |row|
            csv << row
          end
        end
      end
    end

    ### DOWNLOADING ###

    def download(download)
      @downloads << format_download(download)
    end

    def progress(current, total, filename)
      percentage = '%.1f' % (current.to_f / total * 100)
      "\r#{current}/#{total} (#{percentage}%) Downloading #{filename}".ljust(80)[0..79]
    end

    def init_download(options = {})
      @directory = options[:directory] || filename_scrub(url)
      @overwrite = !options[:overwrite].nil? && options[:overwrite]
    end

    def perform_download

      if @downloads.length > 0

        init_download if !@directory

        Dir.mkdir(@directory) if !Dir.exists?(@directory)

        existing = []
        succeeded = []
        failed = []

        total_downloads = @downloads.length

        @downloads.each_with_index do |download, index|

          remote_url = download.keys.first
          local_filename = download[remote_url]

          @err.print progress(index+1, total_downloads, local_filename)

          local_filepath = File.join(@directory, local_filename)

          if !@overwrite && File.exists?(local_filepath)
            existing << download
          else
            begin
              temp_file = open(remote_url, 'rb')
              local_file = File.open(local_filepath, 'w+b') 
              local_file.write(temp_file.read)
              local_file.close
              temp_file.close
              succeeded << download
            rescue SignalException => signal
              # this is so that we can ctrl-c to end the program
              File.delete(local_filepath) if File.exists?(local_filepath)
              raise signal
            rescue Exception => ex
              failed << download.merge(ex: ex)
              File.delete(local_filepath) if File.exists?(local_filepath)
            end
          end
        end

        report_name = write_download_report(failed, existing, succeeded)

        @out.puts "Download complete"
        @out.puts "Failed: #{failed.count}. Pre-existing: #{existing.count}. Succeeded: #{succeeded.count}."
        @out.puts "See #{report_name} for more details."
      end

    end

    def write_download_report(failed, existing, succeeded)
      report_name = File.join @directory, "download_report_#{filename_scrub(Time.now.to_s)}.csv"

      CSV.open(report_name, 'w') do |csv|
        csv << ["Failed", "Pre-existing", "Succeeded"]
        csv << [failed.length, existing.length, succeeded.length]
        csv << []

        csv << ["Remote Url", "Local Filename", "Status"]

        failed.each do |dl|
          ex = dl.delete(:ex)
          mapping = dl.shift
          csv << [mapping[0], mapping[1], ex]
        end

        existing.each do |dl|
          mapping = dl.shift
          csv << [mapping[0], mapping[1], "Pre-existing"]
        end

        succeeded.each do |dl|
          mapping = dl.shift
          csv << [mapping[0], mapping[1], "Success"]
        end
      end

      report_name
    end
  end
end
