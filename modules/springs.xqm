xquery version "3.0";

module namespace springs = "http://bluemountain.princeton.edu/apps/springs";
import module namespace config="http://bluemountain.princeton.edu/apps/springs/config" at "config.xqm";
import module namespace request = "http://exist-db.org/xquery/request";
import module namespace response = "http://exist-db.org/xquery/response";

import module namespace rest = "http://exquery.org/ns/restxq" ;
(:  declare namespace rest="http://exquery.org/ns/restxq"; :)
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace http = "http://expath.org/ns/http-client"; 

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $springs:data-root        as xs:string { "/db/bmtn-data" };
declare variable $springs:metadata        as xs:string { $springs:data-root || "/metadata" };
declare variable $springs:transcriptions  as xs:string { $springs:data-root || "/transcriptions" };



declare function springs:_issue($issueid as xs:string)
as element()
{
    collection($config:transcriptions)//tei:TEI[./tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='bmtnid'] = 'urn:PUL:bluemountain:' || $issueid]
};

declare function springs:_issue-mods($bmtnid as xs:string)
as element()
{
    let $issue := collection($config:metadata)//mods:mods[mods:identifier[@type='bmtn'] = 'urn:PUL:bluemountain:' || $bmtnid]
    return $issue    
};

declare
  %rest:GET
   %rest:path("/springs/serial_works")
  %output:method("json")
function springs:serial-works() {
  <serial_works>
      {
          let $recs := collection($config:metadata)//mods:genre[@authority='bmtn' and .='Periodicals-Title']/ancestor::mods:mods
          for $rec in $recs
          return <serial_work>
                    <title>{ $rec/mods:titleInfo[1]/mods:title[1]/text() }</title>
                    <id>{ substring-after($rec//mods:identifier[@type='bmtn'], 'urn:PUL:bluemountain:') }</id>
                 </serial_work>
      }
  </serial_works>
};

declare
  %rest:GET
   %rest:path("/springs/magazines")
  %output:method("json")
function springs:magazines() {
  <magazines>
      {
          let $recs := collection($config:metadata)//mods:genre[@authority='bmtn' and .='Periodicals-Title']/ancestor::mods:mods
          for $rec in $recs
          return <magazine>
                    <title>{ $rec/mods:titleInfo[1]/mods:title[1]/text() }</title>
                    <id>{ substring-after($rec//mods:identifier[@type='bmtn'], 'urn:PUL:bluemountain:') }</id>
                 </magazine>
      }
  </magazines>
};


declare
  %rest:GET
  %rest:path("/springs/magazines/{$bmtnid}")
  %output:method("json")
function springs:magazine($bmtnid) {
  <magazines>
      {
          let $ids := collection($config:metadata)//mods:identifier[. = 'urn:PUL:bluemountain:' || $bmtnid]
          return 
              <magazine>
                <title>{ $ids[1]/ancestor::mods:mods/mods:titleInfo[1]/mods:title[1]/text() }</title>
                <id>{ $bmtnid }</id>
              </magazine>
      }
  </magazines>
};

declare
  %rest:GET
  %rest:path("/springs/serial_works/{$bmtnid}")
  %output:method("json")
function springs:serial-work($bmtnid) {
  <serial_works>
      {
          let $ids := collection($config:metadata)//mods:identifier[. = 'urn:PUL:bluemountain:' || $bmtnid]
          return 
              <serial_work>
                <title>{ $ids[1]/ancestor::mods:mods/mods:titleInfo[1]/mods:title[1]/text() }</title>
                <id>{ $bmtnid }</id>
              </serial_work>
      }
  </serial_works>
};

declare
  %rest:GET
  %rest:path("/springs/serial_works/{$bmtnid}/publication_works")
function springs:publication_works($bmtnid) {
    let $magazine := collection($config:metadata)//mods:mods[mods:identifer[@type='bmtn'] = 'urn:PUL:bluemountain:' || $bmtnid]
    let $title    := $magazine/mods:titleInfo[1]/mods:title[1]/text()
    let $issues   := collection($config:metadata)//mods:mods[mods:relatedItem[@type='host']/@xlink:href = 'urn:PUL:bluemountain:' || $bmtnid]
    return
        <serial_work>
            <title>{ $title }</title>
            <id>{ $bmtnid }</id>
            <issues>
                {
                    for $issue in $issues
                    let $id   := $issue//mods:identifier[@type='bmtn']/text() 
                    let $date := $issue/mods:originInfo/mods:dateIssued[@keyDate='yes']/text()
                    return
                        <issue>
                            <id>{ $id }</id>
                            <date>{ $date }</date>
                            <fluff/>
                        </issue>
                }
            </issues>
        </serial_work>
};

declare
  %rest:GET
  %rest:path("/springs/magazines/{$bmtnid}/issues")
function springs:publication_works($bmtnid) {
    let $magazine := collection($config:metadata)//mods:mods[mods:identifer[@type='bmtn'] = 'urn:PUL:bluemountain:' || $bmtnid]
    let $title    := $magazine/mods:titleInfo[1]/mods:title[1]/text()
    let $issues   := collection($config:metadata)//mods:mods[mods:relatedItem[@type='host']/@xlink:href = 'urn:PUL:bluemountain:' || $bmtnid]
    return
        <magazine>
            <title>{ $title }</title>
            <id>{ $bmtnid }</id>
            <issues>
                {
                    for $issue in $issues
                    let $id   := $issue//mods:identifier[@type='bmtn']/text() 
                    let $date := $issue/mods:originInfo/mods:dateIssued[@keyDate='yes']
                    order by $date
                    return
                        <issue>
                            <id>{ $id }</id>
                            <date>{ xs:string($date) }</date>
                        </issue>
                }
            </issues>
        </magazine>
};

declare
  %rest:GET
  %rest:path("/springs/issues/{$bmtnid}")
  %rest:produces("application/mods+xml")
function springs:issue-as-mods($bmtnid) {
    springs:_issue-mods($bmtnid)    
};

declare
  %rest:GET
  %rest:path("/springs/issues/{$bmtnid}")
  %rest:produces("application/tei+xml")
function springs:issue-as-tei($bmtnid) {
    springs:_issue($bmtnid)
};

declare
  %rest:GET
  %rest:path("/springs/issues/{$bmtnid}")
  %rest:produces("application/rdf+xml")
function springs:issue-as-rdf($bmtnid) {
    let $issue := springs:_issue-mods($bmtnid)
    let $xsl := doc($config:app-root || "/resources/xsl/mods2crm.xsl")
    return transform:transform($issue, $xsl, ())
};

declare
  %rest:GET
  %rest:path("/springs/constituents/{$bmtnid}")
function springs:constituents($bmtnid) {
    let $issue := collection($config:metadata)//mods:mods[mods:identifier[@type='bmtn'] = 'urn:PUL:bluemountain:' || $bmtnid]
    let $constituents := $issue/mods:relatedItem[@type = 'constituent']
    return
        <issue>
            {
                for $constituent in $constituents
                let $title :=  $constituent/mods:titleInfo[1]/mods:title[1]/text()
                let $bylines := $constituent/mods:name/mods:displayForm
                let $id := xs:string($constituent/@ID)
                return
                    <constituent>
                        <id>{ string-join(($bmtnid,$id), '#') }</id>
                        <title>{ $title }</title>
                        {
                            for $byline in $bylines
                            return
                                <byline>{ $byline/text() }</byline>
                        }
                    </constituent>
            }
        </issue>
};


declare
 %rest:GET
 %rest:path("springs/constituents")
 %rest:query-param("byline", "{$byline}")
 %rest:produces("application/tei+xml")
function springs:constituents-by-byline-tei($byline) {
    let $constituents := springs:constituents-with-byline($byline)
    let $xsl := doc($config:app-root || "/resources/xsl/constituent-to-tei.xsl")
    let $constituents-old := collection($config:transcriptions)//tei:relatedItem[@type='constituent' and ft:query(.//tei:persName, $byline)]
    return
        <teiCorpus xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>Blue Mountain Selections</title>
                        <author>{ $byline }</author>
                    </titleStmt>
                    <publicationStmt>
                        <p>
                            Generated { count($constituents) } hits from { $config:transcriptions }
                        </p>
                    </publicationStmt>
                </fileDesc>
            </teiHeader>
            {
                for $hit in $constituents
                let $cid := $hit/@xml:id
                let $div := $hit/ancestor::tei:TEI//tei:div[@corresp = $cid]
                return 
                    <TEI>
                        <teiHeader>
                            <fileDesc>
                                <titleStmt>
                                    <title>
                                        { $hit/tei:biblStruct }
                                    </title>
                                </titleStmt>
                        
                            </fileDesc>
                            
                        </teiHeader>
                        <text>
                            <body>
                                { $div }
                            </body>
                        </text>                
                    </TEI>
            }
        
        </teiCorpus>
 };
 
declare
  %rest:GET
  %rest:path("/springs/constituent/{$issueid}/{$constid}")
    %rest:produces("text/plain")
function springs:constituent-plaintext($issueid, $constid) {
    let $issue := springs:_issue($issueid)
    let $constituent := $issue//tei:div[@corresp = $constid]
    let $xsl := doc($config:app-root || "/resources/xsl/tei2txt.xsl")
    return transform:transform($constituent, $xsl, ())
};

declare
  %rest:GET
  %rest:path("/springs/constituent/{$issueid}/{$constid}")
  %rest:produces("application/tei+xml")
function springs:constituent-tei($issueid, $constid) {
    let $issue := springs:_issue($issueid)
    let $constituent := $issue//tei:div[@corresp = $constid]
    return $constituent
};

declare
    %rest:GET
    %rest:path("/springs/text/{$issueid}/{$constid}")
    %output:method("text")
function springs:constituent-text($issueid as xs:string, $constid as xs:string)
{
    let $issue := springs:_issue($issueid)
    let $constituent := $issue//tei:div[@corresp = $constid]
    return $constituent
};

declare
 %rest:GET
 %rest:path("/springs/text/{$issueid}")
function springs:text($issueid) {
    let $xsl := doc($config:app-root || "/resources/xsl/tei2txt.xsl")
    let $issue := springs:_issue($issueid)
    return transform:transform($issue, $xsl, ())
};

declare function springs:constituents-with-byline($byline as xs:string)
as element()*
{
    collection($config:transcriptions)//tei:relatedItem[ft:query(.//tei:persName, $byline)]
};

declare
 %rest:GET
 %rest:path("/springs/iiif/collection/top")
function springs:collection-top-xml()
{
    let $recs := collection($config:metadata)//mods:genre[@authority='bmtn' and .='Periodicals-Title']/ancestor::mods:mods
    let $xsl := doc($config:app-root || "/resources/xsl/bmtn-collection-top.xsl") 
    
    return 
    (
        <rest:response>
            <http:response>
                <http:header name="access-control-allow-origin" value="*"/>
            </http:response>
        </rest:response>,
    
    transform:transform(
        <collection level="top">
            <titles>{ $recs }</titles>
        </collection>,
    $xsl, ())
    )
};

declare
 %rest:GET
 %rest:path("/springs/iiif/collection/{$bmtnid}")
function springs:collection-xml($bmtnid)
{
    let $fullid := concat('urn:PUL:bluemountain:', $bmtnid)
    let $titlerec := collection($config:metadata)//mods:identifier[@type='bmtn'][. = $fullid]/ancestor::mods:mods
    let $issuerecs :=
        collection($config:metadata)//mods:mods[mods:relatedItem[@type='host'][@xlink:href= $fullid]]
    let $xsl := doc($config:app-root || "/resources/xsl/bmtn-collection-top.xsl") 
    let $baseURI := $config:springs-root || '/iiif'

    return
    (
        <rest:response>
            <http:response>
                <http:header name="access-control-allow-origin" value="*"/>
            </http:response>
        </rest:response>,
    
        transform:transform(<collection>
            <title>{ $titlerec }</title>
            <issues>{ $issuerecs }</issues>
        </collection>, $xsl, 
            <parameters>
                <param name="baseURI" value="{ $baseURI }"/>
            </parameters>
        )
        
    )
};

declare
 %rest:GET
 %rest:path("/springs/iiif/{$issueid}/manifest")
function springs:mets-to-manifest-xml($issueid) {
    let $issue := springs:_issue-mods($issueid)
    let $baseURI := $config:springs-root || '/iiif'
    let $xsl := doc($config:app-root || "/resources/xsl/bmtn-manifest.xsl")
    return transform:transform($issue/ancestor::mets:mets, $xsl,             <parameters>
                <param name="baseURI" value="{ $baseURI }"/>
            </parameters>)
};

declare
 %rest:GET
 %rest:path("/springs/iiif/{$issueid}/manifest.json")
 %output:method("text")
 %rest:produces("application/json")
function springs:mets-to-manifest-json($issueid) {
    let $manifest-xml := springs:mets-to-manifest-xml($issueid)
    let $xsl := doc($config:app-root || "/resources/xsl/xml2json.xsl")
    
    return 
    (
        <rest:response>
            <http:response>
                <http:header name="access-control-allow-origin" value="*"/>
            </http:response>
        </rest:response>,
    
    transform:transform($manifest-xml, $xsl, ())
    )
};

declare function springs:_issue-label($issue as element())
{
    "a label"
};
declare function springs:_bylines-from-issue($issueid as xs:string)
as element()+
{
    let $issue := springs:_issue-mods($issueid)
    let $creators := $issue//mods:roleTerm[. = 'cre']
    return $creators/ancestor::mods:name/mods:displayForm
};

declare
 %rest: GET
 %rest:path("/springs/contributors/{$issueid}")
 %output:method("text")
 %rest:produces("text/csv")
 
function springs:contributors-from-issue-csv($issueid) {
    let $issue := springs:_issue-mods($issueid)
    let $bylines := springs:_bylines-from-issue($issueid)
    let $issue-label := springs:_issue-label($issue)
    return
    (
    concat(string-join(('bmtnid', 'label', 'contributorid', 'byline', 'contributionid', 'title'), ','), codepoints-to-string(10)),
    for $byline in $bylines
        let $contributorid := 
            if ($byline/ancestor::mods:name/@authority = 'viaf')
                then xs:string($byline/ancestor::mods:name/@valueURI)
            else ()
        let $constituentid := xs:string($byline/ancestor::mods:relatedItem[@type='constituent'][1]/@ID)
        let $title := xs:string($byline/ancestor::mods:relatedItem[@type='constituent'][1]/mods:titleInfo[1])
        return
            concat(string-join(($issueid, $issue-label, $contributorid, xs:string($byline), $constituentid, $title), ','), codepoints-to-string(10))
    )
 
};

declare 
 %rest: GET
 %rest:path("/springs/contributors/{$issueid}")
 %output:method("json")
 %rest:produces("application/json")

 
function springs:contributors-from-issue($issueid) {
    let $issue := springs:_issue-mods($issueid)
    let $bylines := springs:_bylines-from-issue($issueid)
    let $issue-label := springs:_issue-label($issue)
  
    return
        <contributors> {
          for $byline in $bylines
          let $contributorid := 
            if ($byline/ancestor::mods:name/@authority = 'viaf')
                then xs:string($byline/ancestor::mods:name/@valueURI)
            else ()
          let $constituentid := xs:string($byline/ancestor::mods:relatedItem[@type='constituent'][1]/@ID)
          let $title := xs:string($byline/ancestor::mods:relatedItem[@type='constituent'][1]/mods:titleInfo[1])
          return
            <contributor>
                <bmtnid>{ $issueid }</bmtnid>
                <label>{ $issue-label }</label>
                <contributorid>{ $contributorid }</contributorid>
                <byline>{ xs:string($byline) }</byline>
                <contributionid>{ $constituentid }</contributionid>
                <title> { $title }</title>
            </contributor>
        } </contributors>
    
};