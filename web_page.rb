require 'open-uri'
require 'nokogiri'
require 'pry'

class Web
  ASSETS = %i[img link script]

  attr_reader :web_pages, :meta_data, :flag
  attr_accessor :host, :url, :file_path, :content, :data, :new_asset_path

  def  initialize
    @flag = true if ARGV[0].include?('metadata')
    @web_pages = valid_urls
    @meta_data = []
  end

  def call
    web_pages.each do |page|
      self.url = page
      self.host = URI.parse(url).host; new_dir

      self.content = read_file url
      self.data = Nokogiri::HTML::DocumentFragment.parse(content)
      save_assets_and_html
    end
    
    File.open("./output.txt","w") do |f|
      f.write(meta_data)
    end
  
    meta_data
  end

  private

  def save_assets_and_html
    web_page_path
    meta_data << set_meta if flag
    assets
    URI.open(file_path, 'wb') do |file|
      file << data
    end
  end

  def valid_urls
    ARGV.select{|arg| arg if valid_url?(arg) }
  end

  def valid_url?(url)
    URI.parse(url).kind_of?(URI::HTTP)
  end

  def extention?(path)
    false unless path
    !File.extname(URI.parse(path).path).empty?
  end

  def link_count
    data.search('a').count
  end

  def img_count
    data.search('img').count
  end

  def set_meta
    {
      site: url,
      num_links: link_count,
      images: img_count,
      last_fetch: timestamp
    }
  end

  def host_name
    self.host = URI.parse(url).host
  end

  def timestamp
    Time.now.strftime('%a %b %d %Y %H:%M %Z')
  end

  def assets
    ASSETS.each do |asset|
      send "download_#{asset}s"
    end
  end

  def download_imgs
    data.search('img').each do |asset|
      next if asset['src'] && asset['src'].empty?

      download(asset['src'])
      asset['src'] = new_asset_path
    end
  end

  def download_scripts
    data.search('script').each do |asset|

      next if asset['src'].nil?

      download(asset['src'])
      asset['src'] = new_asset_path
    end
  end

  def download_links
    data.search('link').each do |asset|
      next if asset['src'] && asset['src'].empty?

      download(asset['href'])
      asset['href'] = new_asset_path
    end
  end

  def download(asset_path)
    asset_path = valid_url?(asset_path) ? asset_path : "#{url}/#{asset_path}"
    return asset_path unless extention?(asset_path)
    self.new_asset_path = "./#{host}/#{fetch_asset_name(asset_path)}".gsub('?','%3F')

    save_file(new_asset_path, read_file(asset_path))
  end

  def fetch_asset_name(asset_path)
    asset_path.split('/').last
  end

  def read_file(f_path)
    URI.open(f_path).read rescue nil
  end
  def save_file(f_path, f_data)
    URI.open(f_path, 'wb') do |file|
      file << f_data
    end unless f_data.nil?
  end

  def new_dir
    Dir.mkdir(host) unless Dir.exists?(host)
  end

  def web_page_path
    self.file_path = "./#{host}.html"
  end


end

p Web.new.call
