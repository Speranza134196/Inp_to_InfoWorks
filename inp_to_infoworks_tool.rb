require 'csv'
require 'fileutils'

class INPToInfoWorksExporter
  def initialize(inp_path, output_dir)
    @inp_path = inp_path
    @output_dir = output_dir
    @sections = {}
    @coordinates = {}
  end

  def run
    parse_inp
    export_nodes_csv
    export_links_csv
    puts "✅ Export complete! Files saved to #{@output_dir}"
  end

  private

  def parse_inp
    current_section = nil
    File.readlines(@inp_path).each do |line|
      line.strip!
      next if line.empty? || line.start_with?(";")

      if line =~ /^\[(.+)\]$/
        current_section = $1.upcase
        @sections[current_section] ||= []
      elsif current_section == "COORDINATES"
        parts = line.split
        @coordinates[parts[0]] = { x: parts[1], y: parts[2] }
      elsif current_section
        @sections[current_section] << line.split
      end
    end
  end

def export_nodes_csv
  path = File.join(@output_dir, "nodes.csv")
  CSV.open(path, "w") do |csv|
    csv << ["Node ID", "X", "Y", "Ground Level", "Demand"]
    (@sections["JUNCTIONS"] || []).each do |row|
      id, elev, demand = row[0..2]  # Safely slices the first 3
      coords = @coordinates[id] || { x: "", y: "" }
      csv << [id, coords[:x], coords[:y], elev, demand]
    end
  end
end

  def export_links_csv
    path = File.join(@output_dir, "links.csv")
    CSV.open(path, "w") do |csv|
      csv << ["Link ID", "From Node", "To Node", "Length", "Diameter", "Roughness", "Status"]
      (@sections["PIPES"] || []).each do |row|
	id, from, to, length, diameter, roughness, _minor_loss, status = (row + [nil] * 8)[0..7]
        csv << [id, from, to, length, diameter, roughness, status]
      end
    end
  end
end
