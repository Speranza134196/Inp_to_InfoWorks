# 💧 INP to CSV Exporter (Web App)

This Ruby + Sinatra web application allows you to upload EPANET `.inp` files and automatically convert them into multiple InfoWorks-compatible CSV exports.

---

## 🚀 Features

- Upload any `.inp` file
- Parses and extracts key hydraulic network components
- Generates the following CSV files:
  - `nodes.csv` – Junctions with coordinates, elevations, and demand
  - `links.csv` – Pipes with geometry and hydraulic info
  - `reservoirs.csv` – Reservoirs with heads and patterns
  - `tanks.csv` – Tank definitions and parameters
  - `valves.csv` – Valve types, sizes, and settings
  - `demands.csv` – Additional demands by node and pattern
- ZIP archive download of all files
- Browser-based user interface
- Fully deployable on platforms like [Render](https://render.com/)

---

## 🖥️ Run Locally

### Prerequisites
- Ruby 3.0 or higher
- Bundler (`gem install bundler`)

### Installation

```bash
bundle install
bundle lock --add-platform x86_64-linux
```

### Launch Server

```bash
bundle exec rackup
```

Then open:  
👉 `http://localhost:9292`

---

## 🌐 Deploy to Render

1. Push to GitHub
2. Create a new Web Service on Render
3. Set:
   - **Environment**: Ruby
   - **Build Command**: `bundle install`
   - **Start Command**: `bundle exec rackup`
4. Ensure your `Gemfile.lock` includes `x86_64-linux` platform

---

## 📁 Project Structure

```
├── app.rb                   # Sinatra web app
├── inp_to_infoworks_tool.rb # Core INP parsing and CSV logic
├── views/
│   └── index.erb            # HTML view
├── public/
│   ├── logo.png             # Optional branding
│   └── downloads/           # CSV/ZIP files saved here
├── uploads/                 # Temp file storage
├── config.ru                # Rackup entry point
├── Gemfile                  # Ruby dependencies
└── README.md                # You're reading it!
```

---

## 📬 License

MIT – feel free to use, modify, and share.
