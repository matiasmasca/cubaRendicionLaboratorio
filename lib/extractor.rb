# encoding: utf-8

# Reglas de Negocio deducidas
# - 129 caracteres por linea.
# - TRANSPORTE, lleva el Total del paciente, entre registros.
# LINEA Paciente.
# - Paciente inicia en: "0\s\s-""
# -- DNI: inicia en caracter 20 al 27.
# -- Nro. Beneficiacio: 10 digitos
# -- Apellido y nombre: arranca en 42 hasta 85
# -- Origen: 86 al 88
# -- Numero Paciente: 89 al 94
# -- Ficha: 96 al 99
# -- Salto de linea.

# Linea Estudio.
# -- Fecha: 0 al 10 DD/MM/AAAA
# -- blnaco: 11
# -- NOMENCLADOR: 12 al 17
# -- blanco: 18..20 
# -- NOMBRE DE ANALISIS: 19..85 
# -- CANTIDAD: 86..89
# -- blanco: 90..106
# -- PRECIO UNITARIO: 107..115 - Formato: 9.999,99
# -- SUBTOTAL:117..128 - Formato: 9.999,99

# Linea Total Paciente:
# -- "Total Paciente:" 42 a 56
# -- blanco: 57 a 61
# -- Fecha: 62 al 71. Formato: DD/MM/AAAA
# -- blanco: 72 - 107/6
# -- Monto: 108 al 115 - Formato: 9.999,99
# -- blanco: 116 al 120/199
# -- Monto: 121 al 128 - Formato: 9.999,99

# CIERRE:
# Linea 1: 
# -- Firma y sello responsable: 1 al 25.
# -- blanco: 26 al 55.
# -- TRANSPORTE 56 a 65
# -- blanco: 66 a 81/80
# -- : $ 82 a 84
# -- blanco: 85 a 106/7.
# -- Monto transporte: 106 a 115 - Formato: 9.999,99
# -- blanco: 116 al 120/199
# -- Monto: 121 al 128 - Formato: 9.999,99
# Linea: A CARGO DEL BENEFICIARIO 
# -- blanco: 1 a 55
# -- cadena "A CARGO DEL BENEFICIARIO": 56 a 79
# -- blanco: 80 a 81
# -- : $ 82 a 84 [aca puede venir un salto de linea si no hay nada]
# -- blanco: 85 a 106/7.
# -- Monto transporte: 106 a 115 - Formato: 9.999,99
# -- blanco: 116 al 120/199
# -- Monto: 121 al 128 - Formato: 9.999,99

# # Saltar 22 lineas desde Firma y Sello y seguir hasta encontrar otro paciente.
class Extractor

def initialize
 @url_archivo = ""
 @contenido = []
 @pacientes = []
 @servicios = []
end

def leer_archivo(tempfile)
  @contenido = IO.readlines tempfile
  #puts @contenido
end

def buscar_pacientes(lineas)
  lineas.each_with_index do |linea, index|
    linea.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => "")
     if linea.match(/0\s\s-/)
        paciente = Hash.new
        # - Paciente inicia en: "0\s\s-""
        paciente.store("inicia", index)
        # -- DNI: inicia en caracter 20 al 27.
        paciente_dni = linea[19..26]
        paciente.store("dni", "#{paciente_dni}")
        # -- Nro. Beneficiacio: 10 digitos
        paciente_nro_beneficiario = linea[27..37]
        paciente.store("nro_beneficiario", "#{paciente_nro_beneficiario}")
        # -- Apellido y nombre: arranca en 42 hasta 85
        paciente_full_mame = linea[41..83].strip!
        paciente.store("full_mame", "#{paciente_full_mame}")
        # -- Origen: 86 al 88
        paciente_origin = linea[84..86]
        paciente.store("origin", "#{paciente_origin}")
        # -- Numero Paciente: 89 al 94
        paciente_nro_paciente = linea[87..93]
        paciente.store("nro_paciente", "#{paciente_nro_paciente}")
        # -- Ficha: 96 al 99
        paciente_ficha = linea[95..98]
        paciente.store("ficha", "#{paciente_ficha}")
        # -- Salto de linea.
        @pacientes << paciente
     end
  end
  #puts @pacientes
end

def servicios_pacientes(lineas)
      # Lineas estudios
      paciente_actual = 0 # @pacientes.first["inicia"]
      #puts "\e[0;34m\e[47m\ Cambio paciente. #{@pacientes[nro_index]["inicia"]} \e[m"

      lineas.each_with_index do |linea, index|
        linea.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => "")
        if linea.match(/0\s\s-/)
          paciente_actual = linea[19..26].to_i
          #puts "\e[0;34m\e[47m\ Cambio paciente. #{@pacientes[paciente_actual]} \e[m"
        end

        if linea.match(/\A(0?[1-9]|[12][0-9]|3[01])[\/](0?[1-9]|1[012])[\/](19|20)\d{2}/)
          servicios = Hash.new
          servicios.store("paciente", "#{paciente_actual}")
          fecha = linea[0..9] #DateTime.strptime(linea[0..9].to_s, '%d/%m/%Y')            
          servicios.store("fecha", "#{fecha}")
          # -- Fecha: 0 al 10 DD/MM/AAAA
          # -- blnaco: 11
          # -- NOMENCLADOR: 12 al 17
          nomenclador = linea[11..17].to_i
          servicios.store("nomenclador", "#{nomenclador}")
          # -- blanco: 18..20 
          # -- NOMBRE DE ANALISIS: 21..85
          nombre_analisis = linea[20..83].strip!
          servicios.store("nombre_analisis", "#{nombre_analisis}") 
          # -- CANTIDAD: 86..89
          cantidad  = linea[86..89].to_i
          servicios.store("cantidad", "#{cantidad}")
          # -- blanco: 90..106
          # -- PRECIO UNITARIO: 107..115 - Formato: 9.999,99
          precio_unitario  = linea[105..115].to_f
          servicios.store("precio_unitario", "#{precio_unitario}")
          # -- SUBTOTAL:117..128 - Formato: 9.999,99
          subtotal  = linea[118..128].to_f
          servicios.store("subtotal", "#{subtotal}")
          #puts servicios
          @servicios << servicios
        end
      end
     #puts @servicios
end

# Dead CODE:
# def leer_db_fox(archivo)
#   #https://github.com/infused/dbf
#   require 'dbf'
#   database = DBF::Table.new(archivo)
#   database.each do |record|
#     #puts record
#   end
#   #puts(database.schema)
# end
def servicios_paciente(dni)
  #puts "\e[0;34m\e[47m\ Paciente. #{dni} \e[m"
  servicios_cliente = @servicios.select { |item|  item["paciente"] == dni  } 
end

def exportar_osecac(servicios)
  lineas = []
  @pacientes.each do |paciente|
    #puts paciente
    #{"inicia"=>14, "dni"=>"40047880", "nro_beneficiario"=>"0000092594 ", "full_mame"=>"ACOSTA AUGUSTO", "origin"=>" 0 ", "nro_paciente"=>" 785288", "ficha"=>"\n"}
    servicios_cliente = servicios_paciente(paciente["dni"])
    
    servicios_cliente.each do |servicio_prestado| 
      linea = []
      linea << "DNI"
      linea << servicio_prestado["paciente"]
      linea << paciente["full_mame"]
      linea << servicio_prestado["fecha"]
      linea << servicio_prestado["nomenclador"].rjust(6, '0').to_s
      linea << servicio_prestado["cantidad"]
      linea << servicio_prestado["precio_unitario"].to_f
      linea << servicio_prestado["subtotal"].to_f
      lineas << linea
    end
    #{"paciente"=>"38716191", "fecha"=>"04/03/2015", "nomenclador"=>"1", "nombre_analisis"=>"ACTO BIOQUIMICO", "cantidad"=>"1", "precio_unitario"=>"31.0", "subtotal"=>"31.0"}
 end
 exportar_a_excel(lineas)
end

def exportar_a_excel(lineas)
  require 'writeexcel'
  # Create a new Excel Workbook
  path = "./tmp/OSECAC#{Time.now.day}_#{Time.now.month}_#{Time.now.year}_terciar.xls"
  workbook = WriteExcel.new(path)

  # Add worksheet(s)
  worksheet  = workbook.add_worksheet
  worksheet2 = workbook.add_worksheet

  format_encabezado = workbook.add_format
  format_encabezado.set_bold
  format_encabezado.set_color('black')
  format_encabezado.set_align('left')

  #Encabezados
  worksheet.write('A1', 'NUMERO PRESTADOR OSECAC  18116', format_encabezado)
  worksheet.write('A2', 'BOTELLO,  GUILLERMO JOSE', format_encabezado)
  worksheet.write('A3', 'CUIT: 20 - 10032562 - 5', format_encabezado)
  worksheet.write('A4', 'TIPO DOC.', format_encabezado)
  worksheet.write('D2', 'MES DE MARZO DE 2015', format_encabezado)
  worksheet.write('B4', 'NRO DOC.', format_encabezado)
  worksheet.write('C4', 'APELLIDO Y NOMBRE', format_encabezado)
  worksheet.write('D4', 'FECHA', format_encabezado)
  worksheet.write('E4', 'CODIGO', format_encabezado)
  worksheet.write('F4', 'CANT.', format_encabezado)
  worksheet.write('G4', 'UNITARIO', format_encabezado)
  worksheet.write('H4', 'PRECIO', format_encabezado)
  worksheet.set_column('B:B', 8)
  worksheet.set_column('C:C', 30) # Columns C width set to 30
  worksheet.set_column('D:D', 10)
  worksheet.set_column('E:E', 6)
  worksheet.set_column('F:F', 4)
  worksheet.set_column('G:G', 9)
  worksheet.set_column('H:H', 9)
  
  #Recorrer.
  format_row = workbook.add_format
  format_row.set_align('vjustify')

  i=5
  lineas.each do |linea|
    worksheet.write_row("A#{i}", linea, format_row)
    worksheet.write("H#{i}", "=F#{i}*G#{i}", format_row)
    i += 1
  end
    worksheet.write("C#{i}", 'TOTAL', format_encabezado)
    worksheet.write("H#{i}", "=SUM(H5:H#{i-1})", format_encabezado)
  
  # write to file
  workbook.close
  path
end

end

#e = Extractor.new
#e.leer_archivo("input-app 00080403.002_salida_sistema_nuevo")
#leer_archivo("sistema_nuevo.009")
#leer_archivo("00080903.101.txt")
#leer_db_fox("UNNE.DBF")

#e.buscar_pacientes(@contenido)

#e.servicios_pacientes(@contenido)

#e.exportar_osecac(@servicios)
