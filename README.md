***cubaLab Rendiciones***
===
Repositorio para "cubaLab Rendiciones" una app. que toma un archivo de texto plano (un informe de rendiciones) y lo extrae a un archivo Excel con cierto formato y a otro archivo de texto plano con un formato muy especifico.

Es desarrollada con Ruby 2.2.0. y el framework Cuba

Toda contribución (sugerencias de cambio), consejo, critica constructiva, consultas son bienvenidas.

**Herramientas**.
  - Para la Integración Continua: **Travis-ci**
  - Para el deploy, el servicio de hosting: **Heroku**

**Nostas**.
  - Para hacer correr la aplicación: rakeup config.ru
  - Tiene que tener una carpeta "tmp", que es lo que usa en el servidor de producción.

**Servicios Externos.**
-----------------------
[![Build Status](https://travis-ci.org/matiasmasca/cubaRendicionLaboratorio.svg)](https://travis-ci.org/matiasmasca/cubaRendicionLaboratorio)

Licencia:
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)

**Notas Técnicas**
===========

* Ruby version:
    ruby 2.2

* Cuba version:
    cuba 3.4.0

* Rack version: 
	rack 1.6.4


  ¿Cómo contribuir?
  ============
  Necesitarás saber manejar git, si aun no lo conoces: http://bit.ly/probargit
    1. Hace una copia del repositorio (Fork it). Una guía en https://help.github.com/articles/fork-a-repo/
    2. Crea una nueva rama  (git checkout -b MiAporte)
    3. Hacer los cambios que creas necesarios, que agreguen valor a la aplicación.
    4. Agregar las pruebas que pasen para tus cambios.
    5. Comprometer tus cambios (git commit -am 'Mensaje de que cambias')
    6. Enviar tu rama cons sus cambios (git push origin MiAporte)
    7. Ver si pasa el build en Travis: https://travis-ci.org/matiasmasca/cubaRendicionLaboratorio
    8. Se crea un nuevo Pull Request que debe ser aprobado.

  Contributing
  ============

    1. Fork it
    2. Create your feature branch (`git checkout -b my-new-feature`)
    3. Commit your changes (`git commit -am 'Add some feature'`)
    4. Push to the branch (`git push origin my-new-feature`)
    5. Create new Pull Request

    e=======

    Copyright (c) 2015  Matias Mascazzini

    MIT License [![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](http://opensource.org/licenses/MIT)

    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

    Copyright (c) 2015  Matias Mascazzini
    
    Se concede permiso por la presente, de forma gratuita, a cualquier persona que obtenga una copia de este software y de los archivos de documentación asociados (el "Software"), para utilizar el Software sin restricción, incluyendo sin limitación los derechos de usar, copiar, modificar, fusionar, publicar, distribuir, sublicenciar, y/o vender copias de este Software, y para permitir a las personas a las que se les proporcione el Software a hacer lo mismo, sujeto a las siguientes condiciones:

    El aviso de copyright anterior y este aviso de permiso se incluirán en todas las copias o partes sustanciales del Software.

    EL SOFTWARE SE PROPORCIONA "TAL CUAL", SIN GARANTÍA DE NINGÚN TIPO, EXPRESA O IMPLÍCITA, INCLUYENDO PERO NO LIMITADO A GARANTÍAS DE COMERCIALIZACIÓN, IDONEIDAD PARA UN PROPÓSITO PARTICULAR Y NO INFRACCIÓN. EN NINGÚN CASO LOS AUTORES O TITULARES DEL COPYRIGHT SERÁN RESPONSABLES DE NINGUNA RECLAMACIÓN, DAÑOS U OTRAS RESPONSABILIDADES, YA SEA EN UN LITIGIO, AGRAVIO O DE OTRO MODO, QUE SURJA DE O EN CONEXIÓN CON EL SOFTWARE O EL USO U OTRO TIPO DE ACCIONES EN EL SOFTWARE.