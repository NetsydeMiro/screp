require 'nokogiri'
require 'open-uri'
require 'csv'
require 'screp/text_utilities'
require 'screp/http_utilities'
require 'screp/utilities'

class Screp
  include TextUtilities, HttpUtilities

  private

  def initialize(url)
    @url = url

    @page = Nokogiri::HTML(open(@url))
    @selected = [@page]

    @csv = []
    @download = []
  end

  public

  attr_accessor :csv, :download, :page

  def self.scrape(url, &block)
    scraper = Screp.new(url)

    scraper.instance_eval &block

    scraper.output_csv unless @csv.length == 0
    scraper.perform_download unless @download.length == 0 
  end

  def select_each(*args, &block)
    selector, min_index = args
    @selected.last.css(selector).each_with_index do |selected, index|
      if min_index && (index >= min_index)
        @selected.push selected
        instance_exec selected, index, &block
        @selected.pop 
      end
    end
  end

  def init_csv(csv_filename = nil, csv_headers = nil)
    @csv_filename = csv_filename ||= "#{filename_scrub(@url)}.csv"
    @csv << csv_headers if csv_headers
  end

  def init_download(overwrite_existing = false, download_directory = nil) 
    @download_directory = download_directory ||= filename_scrub(@url)
    @overwrite_existing = overwrite_existing

    Dir.mkdir(@download_directory) if !Dir.exists?(@download_directory)
  end

  def output_csv
    init_csv if !@csv_filename

    CSV.open(@csv_filename, 'w') do |csv|
      @csv.each do |row|
        csv << row
      end
    end
  end

  def perform_download(&progress)
    cr_clear = "\r\e"

    progress ||= Proc.new do |current_dl, total_dls, dl|
      print "#{cr_clear}Downloading file #{current_dl} of #{total_dls}, #{dl.values.last}"
    end

    init_download if !@download_directory

    existing_downloads = []
    successful_downloads = []
    failed_downloads = []

    total_downloads = @download.length

    @download.each_with_index do |dl, index|

      progress.call index+1, total_downloads, dl

      remote_url = dl.keys.first
      local_filename = dl[remote_url]
      local_filepath = File.join(@download_directory, local_filename)

      if !@overwrite_existing && File.exists?(local_filepath)
        existing_downloads << dl
      else
        begin
          temp_file = open(remote_url, 'rb')
          local_file = File.open(local_filepath, 'w+b') 
          local_file.write(temp_file.read)
          successful_downloads << dl
        rescue SignalException => signal
          # this is so that we can ctrl-c to end the program
          File.delete(local_filepath) if File.exists?(local_filepath)
          raise signal
        rescue Exception => ex
          failed_downloads << dl.merge(ex: ex)
          File.delete(local_filepath) if File.exists?(local_filepath)
        end
      end
    end
    create_download_report(failed_downloads, 
                           existing_downloads, 
                           successful_downloads)
  end

  def create_download_report(failed, existing, succeeded)
    CSV.open(File.join(@download_directory, "download_report_#{filename_scrub(Time.now.to_s)}.csv"), 'w') do |csv|
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
