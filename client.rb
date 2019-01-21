# encoding: ASCII-8BIT

############################################################################
#   client.rb : client Mivisu SSIL V2
#
# Usage :
#    > ruby client.rb  hostname srv-port  
############################################################################
require_relative 'model.rb'
require 'minitcp'
require 'pp'

if ARGV.size<2
 puts "Usage :  >ruby rad.rb  srv-port  [config.rb]"
 exit 0
end
$hostname=ARGV.shift
$port=ARGV.shift.to_i



###############################################################
##   reception messages 
###############################################################

def receive_message(socket,header) 
  #log "header recue #{header.rtype}  size=#{header.lenmessage}"
  if header.lenmessage>0
    bmess=socket.receive_n_bytes(header.lenmessage)
	case header.rtype.mvalue
		when "A"
		  pp RelectureMessage.read(bmess) rescue "Erreur ?"
		else
		  log "message recue non-traite : size=#{header.rtype} #{bmess.inspect}"
	end
  end
end

###############################################################
##                       M a i n
###############################################################


MClient.run_one_shot($hostname,$port) { |socket|
  socket.on_n_receive(9) { |data|
     head=Header.read(data)
     receive_message(socket,head)
  }
  socket.wait_end
  log "Deconnexion socket"
  exit(0)
}
sleep

