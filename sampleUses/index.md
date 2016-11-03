---
layout: page
title: Sample Uses
permalink: /uses/
---

This is a page of sample uses. Lorem Ipsum.


# Revealing Tristan Tzara in Voyant #
*Scenario:* You want to look at patterns of word usage by Tristan Tzara.

Begin by retrieving a TEI corpus of all the constituents authored by Tzara:

``` {.bash}
curl http://localhost:8080/exist/restxq/springs/constituents?byline="Tzara" > /tmp/tzara.tei.xml
``` 


  * Go to [Voyant Tools](http://voyant-tools.org/).
  * In the options menu, change Input Format from Auto-Detect to TEI Corpus
  * Click on the Upload button, navigate you /tmp, and select tzara.tei.xml
  
Your corpus should open in Voyant's main window. Explore!

# Publication Networks #
*Scenario:* You want to look at patterns of co-occurance in *Broom*.

``` {.bash}
curl http://localhost:8080/exist/restxq/springs/contributors/bmtnaap -o /tmp/broom.csv
``` 

  * Go to [Palladio](http://hdlab.stanford.edu/palladio/)
  * Import your file by dragging and dropping it into the data-entry space and clicking Load
  * Verify your data by clicking on the red dots and verifying the special characters
  * Explore various graph settings.
  
  Alternatively, 
  
  * Go to [Raw](http://raw.densitydesign.org/)
