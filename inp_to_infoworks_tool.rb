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
    export_reservoirs_csv
    export_tanks_csv
    export_valves_csv
    export_demands_csv
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
        id, elev, demand = (row + [nil, nil, nil])[0..2]
        coords = @coordinates[id] || { x: "", y: "" }
        csv << [id, coords[:x], coords[:y], elev, demand]
      end
    end
  end

  def export_links_csv
    path = File.join(@output_dir, "links.csv")
    CSV.open(path, "w") do |csv|
      csv << ["Link ID", "From Node", "To Node", "Length", "Diameter", "Roughness", "Status"]
      row_fields = 8
      (@sections["PIPES"] || []).each do |row|
        id, from, to, length, diameter, roughness, _minor_loss, status = (row + [nil] * row_fields)[0..7]
        csv << [id, from, to, length, diameter, roughness, status]
      end
    end
  end

  def export_reservoirs_csv
  path = File.join(@output_dir, "reservoirs.csv")
  CSV.open(path, "w") do |csv|
    csv << ["Node ID", "X", "Y", "Ground Level", "Demand"]
    (@sections["RESERVOIRS"] || []).each do |row|
      id, head, _pattern = (row + [nil, nil])[0..2]
      coords = @coordinates[id] || { x: "", y: "" }
      csv << [id, coords[:x], coords[:y], head, ""]
    end
  end
end

  def export_tanks_csv
  path = File.join(@output_dir, "tanks.csv")
  CSV.open(path, "w") do |csv|
    csv << ["Tank ID", "X", "Y", "Ground Level", "Init Level", "Min Level", "Max Level", "Diameter", "Min Vol", "Vol Curve"]
    (@sections["TANKS"] || []).each do |row|
      id, elev, init, min, max, diam, min_vol, vol_curve = (row + [nil] * 8)[0..7]
      coords = @coordinates[id] || { x: "", y: "" }
      csv << [id, coords[:x], coords[:y], elev, init, min, max, diam, min_vol, vol_curve]
    end
  end
end

  def export_valves_csv
    path = File.join(@output_dir, "valves.csv")
    CSV.open(path, "w") do |csv|
      csv << ["Valve ID", "From Node", "To Node", "Diameter", "Type", "Setting", "Minor Loss"]
      (@sections["VALVES"] || []).each do |row|
        values = (row + [nil] * 7)[0..6]
        csv << values
      end
    end
  end

  def export_demands_csv
    path = File.join(@output_dir, "demands.csv")
    CSV.open(path, "w") do |csv|
      csv << ["Node ID", "Demand", "Pattern"]
      (@sections["DEMANDS"] || []).each do |row|
        id, demand, pattern = (row + [nil, nil])[0..2]
        csv << [id, demand, pattern]
      end
    end
  end
end
