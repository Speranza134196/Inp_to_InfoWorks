require 'sinatra'
require 'fileutils'
require 'zip/file'
require_relative 'inp_to_infoworks_tool'

set :bind, '0.0.0.0'
set :port, 4567
set :public_folder, File.dirname(__FILE__) + '/public'

helpers do
  def zip_folder(folder_path, zip_path)
    entries = Dir.entries(folder_path) - %w[. ..]
    ::Zip::File.open(zip_path, ::Zip::File::CREATE) do |zipfile|
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
  if params[:inp_file] &&
     (tempfile = params[:inp_file][:tempfile]) &&
     (filename = params[:inp_file][:filename])

    saved_path = "./uploads/#{filename}"
    FileUtils.mkdir_p('./uploads')
    File.open(saved_path, 'wb') { |f| f.write(tempfile.read) }

    output_dir = "./uploads/exported_#{File.basename(filename, ".inp")}"
    FileUtils.mkdir_p(output_dir)

    begin
      exporter = INPToInfoWorksExporter.new(saved_path, output_dir)
      exporter.run
      zip_path = "#{output_dir}.zip"
      zip_folder(output_dir, zip_path)

      @download_links = {
        nodes: "#{output_dir}/nodes.csv",
        links: "#{output_dir}/links.csv",
        zip: zip_path
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
