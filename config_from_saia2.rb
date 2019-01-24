#!/usr/bin/ruby
#Copyright (c) 2019 Regis d'Aubarede, The MIT License

require 'nokogiri'
require 'pp'

###############################################################
##? Config de saia, genere des valeurs selon $valueX[voie] ...
###############################################################

filename=Dir.glob("../../saia-miserII-app/src/main/data/bddtr/compiledRtdb/*/xsrv_mivisu.xml").sort.last
(puts "no saia file founded !" ; exit(1)) unless File.exists?(filename)

puts "#{filename} => size= #{File.size(filename)}"
doc = File.open(filename) { |f| Nokogiri::XML(f) }

lstations= doc.xpath("/services/mivisu/var/@station").inject({}) {|h,att|  h[att.value]=1; h }.keys.sort
puts "Nb Stations = #{lstations.size} ..."

nbmes=0
conf = lstations.first(355555).each_with_object({}) { |sta,h|
  hm=doc.css("/services/mivisu/var[@station=\"#{sta}\"]").each_with_object({}) {|el,hm| 
    repere=el["repere"]
	voie=repere[%r{\w+/(\w+)/},1]
	type=repere[%r{\w+/\w+/(.+?)/},1]
	ak="['#{voie}']"
	hm[repere]= { value: '$value' +type[0,1]+ak , klif: '$klif' +type }
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
pp *conf
