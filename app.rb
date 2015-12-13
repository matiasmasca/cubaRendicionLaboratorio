require 'rack'
require "cuba"
require "cuba/safe"
require "cuba/render"
require "erb"
require "pry"

    require 'logger'  
    require 'tempfile' 

#require "better_errors"
Cuba.use Rack::Session::Cookie, :secret => "__a_very_long_string__"

Cuba.plugin Cuba::Safe

Cuba.plugin Cuba::Render

Cuba.define do
  res.headers["X-Frame-Options"] = "ALLOW-FROM http://terciar.info/"
  on root do
      res.redirect("/home")
  end

  on "home" do
    res.write view("index")
  end

  on "tmp", extension("xls") do |file|
    res.headers["Content-Type"] = "application/vnd.ms-excel"
    res.write(IO.read("./tmp/#{file}.xls"))
  end

  on "procesar" do
    on post do
      boton = req.params["submit"]
      archivo = {}
      archivo.store("nombre_original", req.params["files"][0][:filename])
      archivo.store("tempfile", req.env["rack.tempfiles"][0].path)
      @file_data = req.env["rack.tempfiles"][0]
      #binding.pry
      if boton == "Exportar OSECAC"
        require './lib/extractor'
        e = Extractor.new
        contenido = e.leer_archivo(req.env["rack.tempfiles"][0])
        e.buscar_pacientes(contenido)
        servicios = e.servicios_pacientes(contenido)
        path = e.exportar_osecac(servicios)
        #binding.pry
        res.write view("salida", archivo: path)
      end
      #binding.pry
      if boton == "Exportar ISSUNNE"
        require './lib/extractor'
        e = Extractor.new
        contenido = e.leer_archivo(req.env["rack.tempfiles"][0])
        e.buscar_pacientes(contenido)
        servicios = e.servicios_pacientes(contenido)
        path = e.exportar_issune(servicios)
        #binding.pry
        res.write view("salida", archivo: path)
      end
    end

  end
end