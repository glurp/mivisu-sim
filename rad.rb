#!/usr/bin/ruby
# Copyright (c) 2019 Regis d'Aubarede, The MIT License

############################################################################
#   rad.rb : Simulateur RAD / Mivisu SSIL V2
#
# Usage :
#    > ruby rad.rb  srv-port  config_from_saia.rb  process.rb
#
# En absence de config, l'appli genere des donnée pour une station radt mono-pm, mono capteur, un QTV
############################################################################
require_relative 'model.rb'
require 'minitcp'
require 'pp'

if ARGV.size<3
 puts "Usage/ ruby rad.rb  srv-port config.rb process.rb ..."
 exit 0
end
$port=ARGV.shift.to_i

def suspens(on,off,text) 
 Thread.new { loop {
  sleep(rand(on*3/4..on*5/4))
  puts "~~~~~~~~~~~~ Suspension #{text}"
  yield(true)
  sleep(rand(off*1/2..off*3/2))
  puts "~~~~~~~~~~~~ Fin susp #{text}"
  yield(false)
 }}  
end

$conf={}
ARGV.each {|file| 
    puts "\n\nLoading #{file} ========================"
	puts "   #{File.read(file).split(/\r?\n/).select {|l| l=~/##\?/}.first()[3..-1].strip}\n"
	require_relative file
}
puts "\n\n\n\n"


###############################################################
##   Formating message
###############################################################

## envoie mesure de tous les capteurs de la config
def send_mesures(socket)
 i=0
 $conf[:stations].each { |sta,hmes|
    nbmesures=hmes.size 
	i=0
    lmes=hmes.map {|repere,hm|
	  m=eval(hm[:value])
	  k=eval(hm[:klif])
	  [repere,m,k] 
	}
    make_send_message(socket,'A') {
	  make_relecture_mesures(sta, Time.now, values=lmes)
	}
 }
 make_send_message(socket,'N') {
   ConpteRenduFinCycle.new(periode: 20)
 }
end

## envoie ETAT_SYS ETAT_COM ETAT_ALI  toutes les stations de la config
def send_etats_techniques(socket)
  $conf[:stations].each { |sta,pms|
	make_send_message(socket,"C") { make_relecture_etat_technique(sta,Time.now,[1,1,1]) }
  }
end


###############################################################
##   reception messages 
###############################################################

def receive_message(socket,header) 
  if header.lenmessage>0
    bmess=socket.recv(header.lenmessage) 
	log "message recue : #{header.rtype} / #{bmess.inspect}"
  else
    if header.rtype.mvalue=="y"
	  log("message Recue : Demande Relecture")
	else
      log "header recue vide , code non-traite : #{header.inspect}"
	end
  end
end

###############################################################
##                       M a i n
###############################################################


MServer.service($port,"0.0.0.0",22) do |socket|
  log "Connection client from #{socket.addr.last}"
  login=false
  socket.on_n_receive(9) { |data|
     header=Header.read(data)
     receive_message(socket,header)
	 if header.rtype.mvalue=="w"
		 #send_mesures(socket) 
		 send_etats_techniques(socket)
		 send_mesures(socket)
		 login=true
	 end
  }
  socket.on_timer(10_000) { send_mesures(socket) if login} 
  socket.wait_end
  log "Deconnexion socket"
end
sleep

