# Blue Mountain Springs: A RESTful API to Blue Mountain

For more documentation about the project, see the wiki for this repository: https://github.com/Princeton-CDH/bluemountainsprings/wiki

## To Install
Requires eXist-db 3.0 or higher.


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
