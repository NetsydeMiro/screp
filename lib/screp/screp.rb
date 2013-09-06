require_relative 'text_utilities'
require_relative 'http_utilities'
require_relative 'general_utilities'

require 'csv'

module Screp

  class Screp
    include TextUtilities, HttpUtilities, GeneralUtilities

    def initialize(url)
      @url = url

      @page = Nokogiri::HTML(open(@url))
      @selected = [@page]

      @csv = []
      @downloads = []
    end

    attr_accessor :page


    ### PARSING ###

    def count(selector)
      @selected.last.css(selector).count
    end

    def each(*args, &block)
      selector, range = args
      range ||= (0..-1)
      range = (range..range) if range.class == Fixnum
      @selected.last.css(selector)[range].each_with_index do |selected, index|
        @selected.push selected
        instance_exec index, &block
        @selected.pop 
      end
    end

    def first(selector, &block)

      if block
        each(selector, 0, &block)
      else
        @selected.last.css(selector).first
      end
    end

    def last(selector, &block)
      if block
        each(selector, -1, &block)
      else
        @selected.last.css(selector).last
      end
    end

    def method_missing(meth, *args, &block)
      if @selected.last.respond_to? meth
        @selected.last.send meth, *args, &block
      else
        super
      end
    end


    ### CSV LOGGING ###

    def log(*items)
      @csv << items
    end

    def init_log(options = {})
      check_options(options, :filename, :headers)

      @csv_filename = options[:filename] || "#{filename_scrub(@url)}.csv"
      @csv << options[:headers] if options[:headers]
    end

    def write_log
      init_csv if !@csv_filename

      CSV.open(@csv_filename, 'w') do |csv|
        @csv.each do |row|
          csv << row
        end
      end
    end


    ### DOWNLOADING ###

    def download(download)
      @downloads << format_download(download)
    end

    def progress(current, total, filename)
      percentage = '%.1f' % (current.to_f / total * 100)
      "\r\e#{current}/#{total} (#{percentage}%) Downloading #{filename}".ljust(80)[0..79]
    end

    def init_download(options = {})
      @directory = options[:directory] || filename_scrub(@url)
      @overwrite = !options[:overwrite].nil? && options[:overwrite]
    end

    def perform_download(out = $stdout, err = $stderr)

      init_download if !@directory

      Dir.mkdir(@directory) if !Dir.exists?(@directory)

      existing = []
      succeeded = []
      failed = []

      total_downloads = @downloads.length

      @downloads.each_with_index do |download, index|

        remote_url = download.keys.first
        local_filename = download[remote_url]

        err.print progress(index+1, total_downloads, local_filename)

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

      out.puts "Download complete"
      out.puts "Failed: #{failed.count}. Pre-existing: #{existing.count}. Succeeded: #{succeeded.count}."
      out.puts "See #{report_name} for more details."

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

