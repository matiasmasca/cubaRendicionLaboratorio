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
  @u = "" #Para llevar un valor a la vista.
  on root do
      res.redirect("/home")
  end

  on "home" do
    res.write view("index")
  end

  on "license" do
    res.write view("license")
  end

  on "tmp", extension("xls") do |file|
    res.headers["Content-Type"] = "application/vnd.ms-excel"
    res.write(IO.read("./tmp/#{file}.xls"))
  end

  on "tmp", extension("txt") do |file|
    res.headers["Content-Type"] = "text/plain"
    res.write(IO.read("./tmp/#{file}.txt"))
  end

  on "procesar" do
    on post do
      boton = req.params["submit"]
      archivo = {}
      archivo.store("nombre_original", req.params["files"][0][:filename])
      archivo.store("tempfile", req.env["rack.tempfiles"][0].path)
      @file_data = req.env["rack.tempfiles"][0]
      #binding.pry
      require './lib/extractor'
      archivo_procesado_path = ""
      if boton == "Exportar OSECAC"   
        e = Extractor.new
        contenido = e.leer_archivo(req.env["rack.tempfiles"][0])
        e.buscar_pacientes(contenido)
        servicios = e.servicios_pacientes(contenido)
        archivo_procesado_path = e.exportar_osecac(servicios)
      elsif boton == "Exportar ISSUNNE"
        u = Extractor.new
        contenido = u.leer_archivo(req.env["rack.tempfiles"][0])
        u.buscar_pacientes(contenido)
        servicios = u.servicios_pacientes(contenido)
        archivo_procesado_path = u.exportar_issunne(servicios)
        @u = u.total_unne.round(2) #Copia el contenido del objeto en la variable, para poder acceder al valor desde la vista.

        #binding.pry
      end
      if archivo_procesado_path
        if archivo_procesado_path.match(/error/i) #Si el path contiene la palabra
          res.write view("error", mensaje: archivo_procesado_path)
        else
          res.write view("salida", archivo: archivo_procesado_path)
        end
      else
          res.write view("error", mensaje: "Algo salio mal con el archivo")
      end
      #binding.pry
    end

  end
end