# Blue Mountain Springs: A RESTful API to Blue Mountain

Requires eXist-db 3.0 or higher.

To install:


  * clone the repository
  * run ant to create a package jar file in the build/ directory
  * install using eXist's package installer (available in the Dashboard).

For this release, you will also have to import the data into your eXist database.

  * clone the main Blue Mountain repository
  * run ant in the db folder:
      * ant load-conf
      * ant load-pilot
 

  *  clone the Blue Mountain transcriptions repository
  *  run ant in the db folder:
	 *  ant load-conf
	 *  ant load-pilot
