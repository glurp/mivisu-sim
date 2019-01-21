require 'nokogiri'
require 'pp'

=begin
Exemple de configuration  a generer :

$conf={
 frontal: {
	user: "LABOCOM",
	passwd: "labocom",
 },
 stations: {
   "X40.482T" => {
	  "31002988/1/VT/20/0000" => { value: '$valueVT'  , klif: '$klifVT' },
	  "31002988/1/QT/20/0000" => { value: '$valueQT'  , klif: '$klifQT' },
	  "31002988/1/TT/20/0000" => { value: '$valueTT' , klif:  '$klifTT' },
	}
 }
}

Exemple de configuration saia :

en ../../saia-miserII-app/src/main/data/bddtr/compiledRtdb/20190116_190304_463/xserv_mivisu.xml 

<services>
  <mivisu>
    <var id="FRT40050003.MARCHE" stype="l" name="FRT40050003" repere="FRT40050003.MARCHE"></var>
    <var id="FRT40050003.CR_COMMANDE" stype="l" name="FRT40050003" repere="FRT40050003.CR_COMMANDE"></var>
    <var id="FRT40050003.TXT_CR_COMMANDE" stype="l" name="FRT40050003" repere="FRT40050003.TXT_CR_COMMANDE"></var>
    <var id="STA28050567.DYN_ETAT_ALI" stype="l" name="FRT40050003.FRAD4" repere="X40.482T.ETAT_ALIM"></var>
    <var id="STA28050567.DYN_ETAT_SYS" stype="l" name="FRT40050003.FRAD4" repere="X40.482T.ETAT_SYS"></var>
    <var id="STA28050567.DYN_ETAT_COM" stype="l" name="FRT40050003.FRAD4" repere="X40.482T.ETAT_COM"></var>
    <var id="STA28050567.TOP_FIN_ACQ_STATION" stype="l" name="FRT40050003.FRAD4" repere="X40.482T.TOP"></var>
    <var id="MES99015215.DYN_VALEUR" stype="l" name="FRT40050003.FRAD4" station="X40.482T" repere="31002988/1/VT/20/0000"></var>
    <var id="MES99015213.DYN_VALEUR" stype="l" name="FRT40050003.FRAD4" station="X40.482T" repere="31002988/1/TT/20/0000"></var>
    <var id="MES99015211.DYN_VALEUR" stype="l" name="FRT40050003.FRAD4" station="X40.482T" repere="31002988/1/QT/20/0000"></var>
    <var id="MES99015221.DYN_VALEUR" stype="l" name="FRT40050003.FRAD4" station="X40.482T" repere="31002988/2/VT/20/0000"></var>
    <var id="MES99015219.DYN_VALEUR" stype="l" name="FRT40050003.FRAD4" station="X40.482T" repere="31002988/2/TT/20/0000"></var>
    .....
=end

filename=Dir.glob("../../saia-miserII-app/src/main/data/bddtr/compiledRtdb/*/xsrv_mivisu.xml").sort.last
(puts "no saia file founded !" ; exit(1)) unless File.exists?(filename)

puts "#{filename} => size= #{File.size(filename)}"
doc = File.open(filename) { |f| Nokogiri::XML(f) }

lstations= doc.xpath("/services/mivisu/var/@station").inject({}) {|h,att|  h[att.value]=1; h }.keys.sort
puts "Nb Stations = #{lstations.size} ..."

nbmes=0
conf = lstations.first(3).each_with_object({}) { |sta,h|
  hm=doc.css("/services/mivisu/var[@station=\"#{sta}\"]").each_with_object({}) {|el,hm| 
    repere=el["repere"]
	type=repere[%r{\w+/\w+/(.+?)/},1]
	hm[repere]= { value: '$value' +type , klif: '$klif' +type }
  }
  nbmes+=hm.size
  h[sta]=hm if hm.size>0
}
$conf={
 frontal: {
	user: "LABOCOM",
	passwd: "labocom",
 },
 stations: conf 
}
puts "Nb station=> #{conf.size}, nb messures => #{nbmes}"
