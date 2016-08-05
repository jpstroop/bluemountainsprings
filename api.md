---
layout: page
title: APIs
permalink: /apis/
---


Blue Mountain Springs is a project sponsored by the Center for Digital
Humanities at Princeton University. Its aim is to develop a suite of web
services that can be used to to access the assets in Blue Mountain.

Main API
========

The base URI of the API is the following:

> <http://bluemountain.princeton.edu/springs/>

Resource Keys: the Blue Mountain Identifier (bmtnid)
----------------------------------------------------

TK. Will reprise information in the Blue Mountain specifications.

Resources
---------

Blue Mountain Springs 1.0 provides a simple model of Blue Mountain's
resources:

-   Blue Mountain contains a collection of *magazines*.
-   Magazines contain *issues*.
-   Issues contain *constituents* attributed (via *bylines*) to
    *contributors*. Not all bylines have been associated with
    authorized names. API users should be sure they understand the
    distinction between *bylines* and *contributors*.

# magazines

Get representations of the magazines in Blue Mountain. If no
&lt;bmtnid&gt; is given, the service returns a representation of all the
magazines. If a &lt;bmtnid&gt; is supplied, it returns a representation
of the corresponding magazine.

## Request

|Method  | Accept Header       |  URL
|--------+---------------------+---------------------------|
| GET    | text/csv            |  magazines/&lt;bmtnid&gt;? |
| GET    | application/json    |  magazines/&lt;bmtnid&gt;? |
| GET    | application/tei+xml |  magazines/&lt;bmtnid&gt;? |
| GET    | application/rdf+xml |  magazines/&lt;bmtnid&gt;? |
{:.mbtablestyle}


## Response Body by Content Type

### text/csv

Conforms with [RFC 4180](https://www.ietf.org/rfc/rfc4180.txt) where the
record fields are the following:

| Field | Type |
|-------+------|
| bmtnid | xs:string; see above for bmtnid format |
| primaryTitle | xs:string |
| primaryLanguage |  a delimited string of [ISO 639-2](http://www.loc.gov/standards/iso639-2/) codes |
| startDate | w3cdtf |
| endDate |   w3cdtf |
|  issues |   xs:anyuri |

### application/json

A JSON object with the following properties:

|  property  |   type |
|------------+--------|
| bmtnid     |  xs:string; see above for bmtnid format |
| primaryTitle | xs:string |
|  primaryLanguage |  a delimited string of [ISO 639-2](http://www.loc.gov/standards/iso639-2/) codes |
| startDate | w3cdtf |
| endDate | w3cdtf |
| issues  | xs:anyuri |


# issues

Get representations of magazine issues in Blue Mountain.

If no bmtnid is provided, the service returns a representation of all
the magazine issue resources in Blue Mountain. If a &lt;bmtnid&gt; of a
magazine title is supplied, it returns a representation of all the
magazine's issues; if a &lt;bmtnid&gt; of an issue is supplied, the
service returns a representation of the corresponding issue.

## Request

|  Method |  Accept Header       |     URL                    |
|---------+ ---------------------+----------------------------|
|  GET    |  text/csv            |     issues/&lt;bmtnid&gt;? |
|  GET    |  text/plain          |     issues/&lt;bmtnid&gt;? |
|  GET    |  application/json    |     issues/&lt;bmtnid&gt;? |
|  GET    |  application/tei+xml |     issues/&lt;bmtnid&gt;? |
|  GET    |  application/rdf+xml |     issues/&lt;bmtnid&gt;? |

## Response Body by Content Type

### text/csv

Conforms with [RFC 4180](https://www.ietf.org/rfc/rfc4180.txt) where the
record fields are the following:

-   bmtnid
-   title
-   volume
-   number
-   pubDate
-   pubPlace
-   editors
-   contributors
-   contributions
-   advertisements

### application/json

One or more JSON objects with the following properties:

-   bmtnid
-   title
-   volume
-   number
-   pubDate
-   pubPlace
-   editors
-   contributors
-   contributions
-   advertisements

### text/plain

A utf-8-encoded text dump from the TEI transcription or the ALTO OCR.

### application/tei+xml

The complete TEI transcription of the resource. If the resource is a
magazine title, the document returned is a teiCorpus. The facsimile
section is not returned.

### application/rdf+xml

TBD.

# contributors
Get representations of contributors to magazines in Blue Mountain.

If no bmtnid is supplied, the service returns a representation of all
the bylines in Blue Mountain. Otherwise, it returns all the bylines in
the resource specified by the &lt;bmtnid&gt;.

## Request

|  Method |  Accept Header     |    URL                    |
|---------+--------------------+---------------------------|
|  GET    | text/csv            | bylines/&lt;bmtnid&gt;\* |
|  GET    | application/json    | bylines/&lt;bmtnid&gt;\* |
|  GET    | application/tei+xml | bylines/&lt;bmtnid&gt;\* |
|  GET    | application/rdf+xml | bylines/&lt;bmtnid&gt;\* |

## Response Body by Content Type

### text/csv

Conforms with [RFC 4180](https://www.ietf.org/rfc/rfc4180.txt) where the
record fields are the following:

-   bmtnid
-   byline
-   name (if available)
-   title of contribution
-   id of contribution

# contributors

Get representations of contributors to magazines in Blue Mountain.

If no bmtnid is supplied, the service returns a representation of all
the known contributors in Blue Mountain. Otherwise, it returns all the
known contributors in the resource specified by the &lt;bmtnid&gt;.

#### Request

  Method   Accept Header         URL
  -------- --------------------- -------------------------------
  GET      text/csv              contributors/&lt;bmtnid&gt;\*
           application/json      
           application/tei+xml   
           application/rdf+xml   

### constituents

Get representations of constituents of magazines in Blue Mountain.

-   If no bmtnid is supplied, the service returns a representation of
    all constituents in Blue Mountain.
-   If a bmtnid is supplied, the service returns representations of all
    the constituents of the resource identified by that bmtnid:
    -   If the bmtnid is the id of an issue, the service returns all the
        constituents in that issue.
    -   If the bmtnid is the id of a title, the service returns all the
        constituents in that title.

#### Request

  Method   Accept Header         URL
  -------- --------------------- -----------------------------------------------
  GET      text/csv              constituents/&lt;bmtnid&gt;?/&lt;constid&gt;?
           application/json      
           application/tei+xml   
           application/rdf+xml   

IIIF API
========

This API implements the web service specified by the IIIF Presentation
API (<http://iiif.io/api/presentation/2.0/>)

By implementing the IIIF Presentation API, Blue Mountain Springs also
exposes Blue Mountain's resources according to the Shared Canvas data
model.

The base URI of the IIIF API is the following:

> <http://bluemountain.princeton.edu/springs/iiif/>

Resources
---------

### Collections

IIIF collections are used to list the manifests available for viewing,
and to describe the structures, hierarchies or collections that the
physical objects are part of (see [IIIF Presentation API
2.0](http://iiif.io/api/presentation/2.0/#collections)).

The top-level collection/ resource is Blue Mountain's collection proper,
represented as a IIIF collection object containing embedded collection
objects for each magazine title.

#### Request

  Method   Accept Header         URL
  -------- --------------------- ---------------------
  GET      application/json      collection/{bmtnid}
           application/ld+json   

### Manifests

> The IIIF manifest is an object that contains sufficient information
> for a rendering client to initialize itself and begin to display
> something quickly to the user. The manifest resource represents a
> single object and any intellectual work or works embodied within that
> object. In particular it includes the descriptive, rights and linking
> information for the object. It then embeds the sequence(s) of canvases
> that should be rendered to the user.
>
> [<http://iiif.io/api/presentation/2.0/#manifest>](http://iiif.io/api/presentation/2.0/#manifest)

#### Request

  Method   Accept Header         URL
  -------- --------------------- -----------------------
  GET      application/json      {bmtnid}/manifest
           application/ld+json   
  GET      application/xml       {bmtnid}/manifest.xml

#### Response

##### application/json

A manifest.
