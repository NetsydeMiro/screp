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
      #require 'pry'; bind.pry
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

    def csv(*items)
      @csv << items
    end

    def init_csv(options = {})
      check_options(options, :filename, :headers)

      @csv_filename = options[:filename] || "#{filename_scrub(@url)}.csv"
      @csv << options[:headers] if options[:headers]
    end

    def output_csv
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

    def update_progress(current, total, filename)
      print "\r\eDownloading file #{current} of #{total}, #{filename}".ljust(80)[0..79]
    end

    def init_download(options = {})
      @directory = options[:directory] || filename_scrub(@url)
      @overwrite = !options[:overwrite].nil? && options[:overwrite]
    end

    def perform_download(&progress)

      init_download if !@directory

      Dir.mkdir(@directory) if !Dir.exists?(@directory)

      existing_downloads = []
      successful_downloads = []
      failed_downloads = []

      total_downloads = @downloads.length

      @downloads.each_with_index do |download, index|

        remote_url = download.keys.first
        local_filename = download[remote_url]

        update_progress index+1, total_downloads, local_filename

        local_filepath = File.join(@directory, local_filename)

        if !@overwrite && File.exists?(local_filepath)
          existing_downloads << download
        else
          begin
            temp_file = open(remote_url, 'rb')
            local_file = File.open(local_filepath, 'w+b') 
            local_file.write(temp_file.read)
            local_file.close
            successful_downloads << download
          rescue SignalException => signal
            # this is so that we can ctrl-c to end the program
            File.delete(local_filepath) if File.exists?(local_filepath)
            raise signal
          rescue Exception => ex
            failed_downloads << download.merge(ex: ex)
            File.delete(local_filepath) if File.exists?(local_filepath)
          end
        end
      end

      create_download_report(failed_downloads, 
                             existing_downloads, 
                             successful_downloads)
    end

    def create_download_report(failed, existing, succeeded)
      CSV.open(File.join(@directory, "download_report_#{filename_scrub(Time.now.to_s)}.csv"), 'w') do |csv|
        csv << ["Failed", "Pre-existing", "Succeeded", "Total"]
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
    end
  end
end

