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

#Converir cadena a decimal
def string_number_decimal_host(string)
  decimal_point = (1.to_f.to_s)[1] #Para saber cual es el simbolo decimal en el host
   #gsub(/[.,]/, '.' => '', ',' => '.')
  if decimal_point == "."
    #string.sub!(",", decimal_point)
    string.gsub(/[.,]/, '.' => '', ',' => decimal_point)
  elsif decimal_point == ","
    string.gsub(/[.,]/, ',' => '', '.' => decimal_point)
  end
end

class Extractor
  attr_accessor :contenido, :paciente, :servicios, :decimal_point, :periodo, :institucion, :total_unne

  def initialize
   @url_archivo = ""
   @contenido = []
   @pacientes = []
   @servicios = []
   @periodo = ""
   @institucion = ""
   @total_unne = 0
  end

  def leer_archivo(tempfile)
    @contenido = IO.readlines tempfile if File.exist? tempfile
    #puts @contenido
  end

  def buscar_pacientes(lineas)
    lineas.each_with_index do |linea, index|
      #linea.encode!('UTF-8', :undef => :replace, :invalid => :replace, :replace => "") #Me hace perder las ñ
      linea.encode!('UTF-8', 'WINDOWS-1252', :invalid => :replace, :replace => "")
       if linea.match(/0\s\s-0/)
          paciente = Hash.new
          # - Paciente inicia en: "0\s\s-03""
          paciente.store("inicia", index)
          # -- DNI: inicia en caracter 20 al 27.
          paciente_dni = linea[18..26].strip.to_i
          paciente.store("dni", "#{paciente_dni}")
          # -- Nro. Beneficiacio: 10 digitos
          paciente_nro_beneficiario = linea[27..37].strip.to_i
          paciente.store("nro_beneficiario", "#{paciente_nro_beneficiario}")
          # -- Apellido y nombre: arranca en 42 hasta 85
          paciente_full_mame = linea[41..83].strip!
          paciente.store("full_mame", "#{linea[41..83]}")
          #puts "\e[0;34m\e[47m\ Paciente _full: #{paciente_full_mame} \e[m"
          #puts "\e[0;34m\e[47m\ Paciente repetido: #{paciente["full_mame"]} \e[m"
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
          ###!!! Controlar que el DNI no este cargado en el vector.
          ### paciente_dni
          #puts "\e[0;34m\e[47m\ Paciente repetido: #{servicio_prestado["precio_unitario"]} \e[m"
          
          #{"inicia"=>14, "dni"=>"39186284", "nro_beneficiario"=>"", "full_mame"=>"FERNANDEZ MAIRA ELIZABETH", "origin"=>" 0 ", "nro_paciente"=>" 816433", "ficha"=>"178\r"}
          #{"inicia"=>17, "dni"=>"54263999", "nro_beneficiario"=>"", "full_mame"=>"MORALES IGNACIO", "origin"=>" 0 ", "nro_paciente"=>" 816436", "ficha"=>"6206"}
         repetido = false
         @pacientes.each do |item| 
            #puts "* #{item['dni']}"
            #puts "vs. #{paciente_dni}"
            repetido = true if item['dni'].to_i == paciente_dni.to_i
         end
          #puts "arra: #{project_array}"
          @pacientes << paciente unless repetido
       end
       if linea.match(/^Periodo/)
        #Periodo: busca la linea del informe y lo toma de allí
        periodo = linea[13..30].strip
        @periodo = periodo.gsub(/[\/\s]/, '/' => '', ' ' => '')
       end
       if linea.match(/^Institucion/)
        #Periodo: busca la linea del informe y lo toma de allí
        institucion = linea[14..46].strip
        @institucion = institucion.gsub(/[.]/, '.' => '')
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
          if linea.match(/0\s\s-0/)
            paciente_actual = linea[19..26].strip.to_i #DNI paciente
            #puts "\e[0;34m\e[47m\ Cambio paciente. #{@pacientes[paciente_actual]} \e[m"
          end

          if linea.match(/\A(0?[1-9]|[12][0-9]|3[01])[\/](0?[1-9]|1[012])[\/](19|20)\d{2}/)
            servicios = Hash.new
            servicios.store("paciente", "#{paciente_actual}") #DNI
            fecha = linea[0..9].strip #DateTime.strptime(linea[0..9].to_s, '%d/%m/%Y')            
            servicios.store("fecha", "#{fecha}")
            # -- Fecha: 0 al 10 DD/MM/AAAA
            # -- blnaco: 11
            # -- NOMENCLADOR: 12 al 17
            nomenclador = linea[11..17].strip.to_i
            servicios.store("nomenclador", "#{nomenclador}")
            # -- blanco: 18..20 
            # -- NOMBRE DE ANALISIS: 21..85
            nombre_analisis = linea[20..83].strip
            servicios.store("nombre_analisis", "#{nombre_analisis}") 
            # -- CANTIDAD: 86..89
            cantidad  = linea[86..89].strip.to_i
            servicios.store("cantidad", "#{cantidad}")
            # -- blanco: 90..106
            # -- PRECIO UNITARIO: 107..115 - Formato: 9.999,99
            precio_unitario = linea[105..115]
            if precio_unitario
              precio_unitario.strip! 
              precio_unitario = string_number_decimal_host(precio_unitario)
            end
            precio_unitario.gsub!(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2').to_f if precio_unitario
            #puts "\e[0;34m\e[47m\ precio_unitario: #{precio_unitario} \e[m"
            servicios.store("precio_unitario", "#{precio_unitario}")
            # -- SUBTOTAL:117..128 - Formato: 9.999,99
            subtotal = linea[118..128]
            if subtotal
              subtotal.strip!
              subtotal = string_number_decimal_host(subtotal)
            end
            #puts sprintf('%.2f', subtotal)
            servicios.store("subtotal", "#{subtotal}")
            #puts "Linea Servicios Pa: #{servicios}"
            #Ajuste Precio Unitario: el informe trae mal calculado el precio unitario. Aveces le pone el valor del subtotal de la linea.
            servicios["precio_unitario"] = servicios["subtotal"].to_f / servicios["cantidad"].to_i
            #puts "Precio unitario: #{servicios["precio_unitario"]}"
            @servicios << servicios
          end
        end
       #puts @servicios
  end


  def servicios_paciente(dni)
    #puts "\e[0;34m\e[47m\ Paciente. #{dni} \e[m"
    servicios_cliente = @servicios.select { |item|  item["paciente"] == dni  } 
  end

  def exportar_osecac(servicios)
    # Pidieron que se elimine este control de institucion.
    #unless @institucion == "OSECAC" || @institucion == "OSECAC  BONO SOLIDARIO"
    #  puts "\e[0;34m\e[47m\ Institucion: #{@institucion}. \e[m"
    #  return "Error: El archivo no corresponde a OSECAC"
    #end
    lineas = []
    @pacientes.each do |paciente|
      #puts lineas.inspect
      #return if lineas.include?(paciente["dni"])
      #puts "\e[0;34m\e[47m\ paciente dni: #{paciente["dni"]} \e[m"

      #{"inicia"=>14, "dni"=>"40047880", "nro_beneficiario"=>"0000092594 ", "full_mame"=>"ACOSTA AUGUSTO", "origin"=>" 0 ", "nro_paciente"=>" 785288", "ficha"=>"\n"}
      servicios_cliente = servicios_paciente(paciente["dni"])
      #puts "\e[0;34m\e[47m\ Servicios: #{servicios_cliente.inspect} \e[m"
      servicios_cliente.each do |servicio_prestado| 
        linea = []
        linea << "DNI"
        linea << servicio_prestado["paciente"]
        linea << paciente["full_mame"]
        linea << servicio_prestado["fecha"]
        #puts "\e[0;34m\e[47m\ Fecha servicio: #{servicio_prestado["fecha"]} \e[m"
        linea << servicio_prestado["nomenclador"].rjust(6, '0').to_s
        linea << servicio_prestado["nombre_analisis"]
        linea << servicio_prestado["cantidad"].to_i
        linea << servicio_prestado["precio_unitario"]
        linea << servicio_prestado["subtotal"]
        lineas << linea
        #puts "\e[0;34m\e[47m\ linea: #{servicio_prestado["precio_unitario"]} \e[m"
      end
      #{"paciente"=>"38716191", "fecha"=>"04/03/2015", "nomenclador"=>"1", "nombre_analisis"=>"ACTO BIOQUIMICO", "cantidad"=>"1", "precio_unitario"=>"31.0", "subtotal"=>"31.0"}
   end
   
   #Pedido especial: que ordende por fecha de atención.
   lineas.sort_by! { |h| h[3] } #ordena por fecha, que es el 4 valor en el array.
   #lineas.each do |h| 
   # puts "\e[0;34m\e[47m\ h: #{h[2]} \e[m"
   #end
   exportar_a_excel(lineas)
  end

  def exportar_a_excel(lineas)
    require 'writeexcel'
    # Create a new Excel Workbook
    path = "./tmp/OSECAC#{Time.now.day}_#{Time.now.month}_#{Time.now.year}_terciar.xls"
    #path = "OSECAC#{Time.now.day}_#{Time.now.month}_#{Time.now.year}_terciar.xls"
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
    worksheet.write('F4', 'DESCRIPCIÓN', format_encabezado)
    worksheet.write('G4', 'CANT.', format_encabezado)
    worksheet.write('H4', 'UNITARIO', format_encabezado)
    worksheet.write('I4', 'PRECIO', format_encabezado)
    worksheet.set_column('B:B', 8)
    worksheet.set_column('C:C', 30) # Columns C width set to 30
    worksheet.set_column('D:D', 10)
    worksheet.set_column('E:E', 6)
    worksheet.set_column('F:F', 30)
    worksheet.set_column('G:G', 4)
    worksheet.set_column('H:H', 9)
    worksheet.set_column('I:I', 9)
    
    #Recorrer.
    format_row = workbook.add_format
    format_row.set_align('vjustify')
    format_number = workbook.add_format
    format_number.set_align('right')
    format_number.set_num_format(0) #Formato general de numero pre definido por excel
    format_currency = workbook.add_format
    format_currency.set_align('right')
    #format_currency.set_num_format('#.##0,00')
    format_currency.set_num_format(4) #Formato de moneda pre definido por excel
    #worksheet.write(2,  0, 1234.56,   format03)    # 1,234.56

    i=5
    lineas.each do |linea|
      #puts "Linea Excel: #{linea}
      #worksheet.write_row("A#{i}", linea, format_row) #Linea entera.
      worksheet.write("A#{i}", linea[0], format_row)
      worksheet.write("B#{i}", linea[1], format_number)
      worksheet.write("C#{i}", linea[2], format_row)
      worksheet.write("D#{i}", linea[3], format_row)
      worksheet.write("E#{i}", linea[4] , format_number)
      worksheet.write("F#{i}", linea[5] , format_row)
      worksheet.write("G#{i}", linea[6] , format_number)
      worksheet.write("H#{i}", linea[7] , format_currency)
      worksheet.write("I#{i}", "=G#{i}*H#{i}", format_currency)
      i += 1
    end
      worksheet.write("C#{i}", 'TOTAL', format_encabezado)
      worksheet.write("I#{i}", "=SUM(I5:I#{i-1})", format_currency)
    
    # write to file
    workbook.close
    path
  end

  def exportar_issunne(servicios)
    if @institucion != "UNNE" 
      return "Error: El archivo no corresponde a UNNE"
    end
    # Formato Linea
  # IDCliente= 0014
  # TipoFactura= B
  # NumeroFactura= 000000000000 (12chr)
  # ! PeriodoFacturado= 112015 (MesAño) (6chr)
  # ProfesionalAsiste= 00000014 (8chr)
  # IdFuncion = 1 (1chr)
  # ! IDconsulta = 000005352012297 (15chr)
  # ! DniAfiliado = 06745788 (8chr)
  # ! ApellidoNombre = Pepe Argento (60chr) - completar con blancos
  # TipoServicio= 1 (1chr)
  # ! FechaPractica= 12112015 (8chr)
  # ! Practica = 661070 (6chr) (660475 = NBU hemograma) viene 475
  # ! Cantidad = 001 (3chr) - completar con ceros
  # ! Porcentaje = 100 (3chr)
  # ! Importe = 000000000020535 (15chr) sin punto decimal. 205.35
  # ProfesionalIndica = 00000000 (8chr) completar con ceros.
  # CodigoOMS = 0000 (4chr)
  # ! Diagnostico = HEMOGLOBINA GLICOS (80chr) - completar con blancos.
  # ! NumeroVias = 1 (1chr)
  # FinSemana = N (1chr)
  # Nocturno = N (1chr)
  # Feriado = N (1chr)
  # Urgencias = N (1chr)
  # - Regla de Negocio: En caso de que no se tenga información para completar algún campo y sea String se completara con espacios vacíos o S y N según corresponda y si fuera numérico con ceros.

      lineas = []
      @pacientes.each do |paciente|
      #{"inicia"=>14, "dni"=>"40047880", "nro_beneficiario"=>"0000092594 ", "full_mame"=>"ACOSTA AUGUSTO", "origin"=>" 0 ", "nro_paciente"=>" 785288", "ficha"=>"\n"}  
        servicios_cliente = servicios_paciente(paciente["dni"])
        servicios_cliente.each do |servicio_prestado|
        #{"paciente"=>"38716191", "fecha"=>"04/03/2015", "nomenclador"=>"1", "nombre_analisis"=>"ACTO BIOQUIMICO", "cantidad"=>"1", "precio_unitario"=>"31.0", "subtotal"=>"31.0"} 
          next if servicio_prestado["nombre_analisis"] == "ETIQUETA" #salta este servicio que no se factura
          linea = ""
          linea << "0014" #IDCliente
          linea << "B" #TipoFactura
          linea << "000000000000" # NumeroFactura= 000000000000
          linea << "#{@periodo}" #PeriodoFacturado
          linea << "00000014" #ProfesionalAsiste= 00000014 (8chr)
          linea << "1" #IdFuncion = 1 (1chr)
          linea << paciente["nro_beneficiario"].rjust(15, '0').to_s # !!! IDconsulta = 000005352012297 (15chr)
          linea << paciente["dni"].rjust(8, '0').to_s # ! DniAfiliado = 06745788 (8chr)
          linea << paciente["full_mame"].ljust(60, ' ').to_s #! ApellidoNombre = Pepe Argento (60chr) - completar con blancos
          linea << "1" #TipoServicio= 1 (1chr)
          linea << servicio_prestado["fecha"].to_s.gsub(/[\/]/, '/' => '') # ! FechaPractica= 12112015 (8chr)
          linea << servicio_prestado["nomenclador"].rjust(6, '66000').to_s # ! Practica = 661070 (6chr) (660475 = NBU hemograma) viene 475
          linea << servicio_prestado["cantidad"].rjust(3, '0').to_s # ! Cantidad = 001 (3chr) - completar con ceros
          linea << "100" # ! Porcentaje = 100 (3chr)
          linea << servicio_prestado["precio_unitario"].to_s.sub(".","").rjust(15, '0').to_s # ! Importe = 000000000020535 (15chr) sin punto decimal. 205.35
          linea << "00000000" # ProfesionalIndica = 00000000 (8chr) completar con ceros.
          linea << "0000"  # CodigoOMS = 0000 (4chr)
          linea << servicio_prestado["nombre_analisis"].ljust(80, ' ').to_s# ! Diagnostico (80chr) - completar con blancos.
          linea << "1"# ! NumeroVias = 1 (1chr)
          linea << "N"# FinSemana = N (1chr)
          linea << "N"# Nocturno = N (1chr)
          linea << "N"# Feriado = N (1chr)
          linea << "N"# Urgencias = N (1chr)
          lineas << linea
          
          #Esto es para mostrar un total en la vista, para que puedan comparar rapidamente si salio bien el calculo.
          subtotal = servicio_prestado["subtotal"].to_f
          #puts "\e[0;34m\e[47m\ subtotal: #{subtotal} y #{servicio_prestado["subtotal"]} \e[m"
          @total_unne += subtotal
        end
      end
      #Pedido especial: que ordende por fecha de atención.
       lineas.sort_by! { |f| f[10] } #ordena por fecha, que es el 4 valor en el array.
  
      crear_archivo_issunne(lineas)
  end

  def crear_archivo_issunne(lineas)
    #//Fija la ruta del archivo de salida.
    path = "./tmp/UNNE#{Time.now.day}_#{Time.now.month}_#{Time.now.year}_terciar.txt"
    #DEV:# path = "UNNE#{Time.now.day}_#{Time.now.month}_#{Time.now.year}_terciar.txt"
    #//Crear archivo
    File.open(path, 'w') do |salida|
      # '\n' es el retorno de carro
      lineas.each do |linea|
        salida.puts linea
      end
    end
    path
  end

end

# Probar Conversor de punto decimal:
#numero = string_number_decimal_host("10.830,33")
#puts "Numero: #{numero}"
#numero = string_number_decimal_host("80,33")
#puts "Numero: #{numero}"
#numero = string_number_decimal_host("8033")
#puts "Numero: #{numero}"

#Funcionamiento manual.
#para usar el extractor desde ruby, sin Cuba ni nada.
##e = Extractor.new
##e.leer_archivo("prueba_corta")
#leer_archivo("sistema_nuevo.009")
#leer_db_fox("UNNE.DBF")
#puts "el punto decimal es: #{e.decimal_point}"
#e.leer_archivo("00080903.101")

##e.buscar_pacientes(e.contenido)
##puts e.periodo
##puts e.institucion
##e.servicios_pacientes(e.contenido)
##e.exportar_issunne(e.servicios)


#e.buscar_pacientes(@contenido)
#e.servicios_pacientes(@contenido)
#e.exportar_osecac(@servicios)

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
