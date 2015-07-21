xquery version "3.0";

module namespace springs = "http://bluemountain.princeton.edu/apps/springs";
import module namespace config="http://bluemountain.princeton.edu/apps/springs/config" at "config.xqm";

import module namespace rest = "http://exquery.org/ns/restxq" ;
(:  declare namespace rest="http://exquery.org/ns/restxq"; :)
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace mets="http://www.loc.gov/METS/";
declare namespace xlink="http://www.w3.org/1999/xlink";
declare namespace tei="http://www.tei-c.org/ns/1.0";

declare variable $springs:data-root        as xs:string { "/db/bluemtn" };
declare variable $springs:metadata        as xs:string { $springs:data-root || "/metadata" };
declare variable $springs:transcriptions  as xs:string { $springs:data-root || "/transcriptions" };

declare
  %rest:GET
   %rest:path("/springs/serial_works")
  %output:method("json")
function springs:serial-works() {
  <serial_works>
      {
          let $recs := collection($springs:metadata)//mods:genre[@authority='bmtn' and .='Periodicals-Title']/ancestor::mods:mods
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
  %rest:path("/springs/serial_works/{$bmtnid}")
  %output:method("json")
function springs:serial-work($bmtnid) {
  <serial_works>
      {
          let $ids := collection($springs:metadata)//mods:identifier[. = 'urn:PUL:bluemountain:' || $bmtnid]
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
    let $magazine := collection($springs:metadata)//mods:mods[mods:identifer[@type='bmtn'] = 'urn:PUL:bluemountain:' || $bmtnid]
    let $title    := $magazine/mods:titleInfo[1]/mods:title[1]/text()
    let $issues   := collection($springs:metadata)//mods:mods[mods:relatedItem[@type='host']/@xlink:href = 'urn:PUL:bluemountain:' || $bmtnid]
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
  %rest:path("/springs/constituents/{$bmtnid}")
function springs:constituents($bmtnid) {
    let $issue := collection($springs:metadata)//mods:mods[mods:identifier[@type='bmtn'] = 'urn:PUL:bluemountain:' || $bmtnid]
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
  %rest:path("/springs/constituent/{$issueid}/{$constid}")
function springs:constituent($issueid, $constid) {
    let $issue := collection($springs:metadata)//mods:mods[mods:identifier[@type='bmtn'] = 'urn:PUL:bluemountain:' || $issueid]
    let $constituent := $issue//mods:relatedItem[@ID = $constid]
    let $title := xs:string($constituent/mods:titleInfo[1]/mods:title)
    let $bylines := $constituent/mods:name/mods:displayForm
    return
        <constituent>
            <id>{ $issueid }</id>
            <title>{ $title }</title>
            {
                for $byline in $bylines
                return
                    <byline>{ $byline/text() }</byline>
            }
                
        </constituent>
};

declare
 %rest:GET
 %rest:path("/springs/text/{$issueid}")
function springs:text($issueid) {
    let $xsl := doc($config:app-root || "/resources/xsl/tei2txt.xsl")
    let $transcription := collection($springs:transcriptions)//tei:TEI[./tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:idno[@type='bmtnid'] = 'urn:PUL:bluemountain:' || $issueid]
        return transform:transform($transcription, $xsl, ())
};