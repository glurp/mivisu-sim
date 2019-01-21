#!/usr/bin/ruby
# Copyright (c) 2019 Regis d'Aubarede, The MIT License

############################################################################
#   rad.rb : Simulateur RAD / Mivisu SSIL V2
#
# Usage :
#    > ruby rad.rb  srv-port  [config_from_saia.rb]
#
# En absence de config, l'appli genere des donnée pour une station radt mono-pm, mono capteur, un QTV
############################################################################
require_relative 'model.rb'
require 'minitcp'
require 'pp'

if ARGV.size<1
 puts "Usage/ ruby rad.rb  srv-port  [config.rb]"
 exit 0
end
$port=ARGV.shift.to_i

$conf={}
if ARGV.size>0  
  ARGV.each {|file| 
    puts "Loading #{file} ========================"
	require_relative file
  }
else
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
end  
###############################################################
##   Scenarios
###############################################################

Thread.new { loop {
 if rand(1000) > 100
	 $valueVT=Time.now.to_i % 100
	 $valueQT=Time.now.to_i % 10
	 $valueTT=Time.now.to_i % 60
	 $klifVT=0
	 $klifQT=0
	 $klifTT=1
 else
   puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Suspension move mesures 40..60 secondes"
   sleep rand(40..60)
   puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ fin suspension"
 end
 sleep 10
} }

sleep 0.1


###############################################################
##   Formating message
###############################################################

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
	m=make_relecture_mesures(sta, Time.now, values=lmes)
	#pp m
	log m.inspect[0..70]
	Header.new(rtype: Char.v("A") , version: Char.v("2") , lenmessage: m.get_binary_size , a1:0,a2:0,a3:0).write(socket)
	m.write(socket)
 }
end

#io=StringIO.new ; send_mesures(io) ;p io.string ;exit(0)

###############################################################
##   reception messages 
###############################################################

def receive_message(socket,header) 
  if header.lenmessage>0
    bmess=socket.recv(header.lenmessage) 
	log "message recue #{header.rtype} #{bmess.inspect}"
  else
    log "header recue vide #{header.inspect}"
  end
end

###############################################################
##                       M a i n
###############################################################


MServer.service($port,"0.0.0.0",22) { |socket|
  log "Connection client from #{socket.addr.last}"
  send_mesures(socket) 
  socket.on_n_receive(9) { |data|
     head=Header.read(data)
     receive_message(socket,head)
  }
  socket.on_timer(10_000) { send_mesures(socket) } 
  socket.wait_end
  log "Deconnexion socket"
}
sleep

