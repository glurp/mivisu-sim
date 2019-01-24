######################################################################
##?   Process : mesure aleatoire, periode avec suspension evolutions
######################################################################

suspens(120,200,"all") { |s| susp=s }

Thread.new { loop {
	ran=rand(0..20)
	unless susp 
	 $valueVT=(Time.now.to_i % 100) + ran
	 $valueQT=(Time.now.to_i % 10)+ ran
	 $valueTT=(Time.now.to_i % 60)+ ran
	sleep(3)
} }

sleep 0.1