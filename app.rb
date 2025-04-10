require 'sinatra'
require 'fileutils'
require 'zip'
require_relative 'inp_to_infoworks_tool'

set :bind, '0.0.0.0'
set :port, 9292
set :public_folder, File.dirname(__FILE__) + '/public'

helpers do
  def zip_folder(folder_path, zip_path)
    entries = Dir.entries(folder_path) - %w[. ..]
    Zip::File.open(zip_path, Zip::File::CREATE) do |zipfile|
      entries.each do |entry|
        file_path = File.join(folder_path, entry)
        zipfile.add(entry, file_path)
      end
    end
  end
end

get '/' do
  erb :index
end

post '/upload' do
  FileUtils.mkdir_p('./uploads')
  if params[:inp_file] &&
     (tempfile = params[:inp_file][:tempfile]) &&
     (filename = params[:inp_file][:filename])

    saved_path = "./uploads/#{filename}"
    File.open(saved_path, 'wb') { |f| f.write(tempfile.read) }

    output_dir = "./uploads/exported_#{File.basename(filename, ".inp")}"
    FileUtils.mkdir_p(output_dir)

    begin
      exporter = INPToInfoWorksExporter.new(saved_path, output_dir)
      exporter.run

      zip_path = "#{output_dir}.zip"
      zip_folder(output_dir, zip_path)

      # Copy results to public for downloading
      public_path = "./public/downloads/#{File.basename(output_dir)}"
    FileUtils.mkdir_p(public_path)

    # Explicitly copy each CSV file
    %w[nodes links reservoirs tanks valves demands].each do |name|
      src = "#{output_dir}/#{name}.csv"
      dst = "#{public_path}/#{name}.csv"
      FileUtils.cp(src, dst) if File.exist?(src)
    end

    zip_dst = "./public/downloads/#{File.basename(zip_path)}"
    FileUtils.cp(zip_path, zip_dst)

    @download_links = {
      nodes: "/downloads/#{File.basename(output_dir)}/nodes.csv",
      links: "/downloads/#{File.basename(output_dir)}/links.csv",
      reservoirs: "/downloads/#{File.basename(output_dir)}/reservoirs.csv",
      tanks: "/downloads/#{File.basename(output_dir)}/tanks.csv",
      valves: "/downloads/#{File.basename(output_dir)}/valves.csv",
      demands: "/downloads/#{File.basename(output_dir)}/demands.csv",
      zip: "/downloads/#{File.basename(zip_path)}"
    }
      @message = "✅ Exported successfully!"
    rescue => e
      @message = "❌ Error: #{e.message}"
    end
  else
    @message = "❌ No file selected."
  end

  erb :index
end
