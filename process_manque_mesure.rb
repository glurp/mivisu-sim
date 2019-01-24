###############################################################
##?   Process : mesures aleatoire, periode avec disparition des VT, periode avec suspension evolutions
###############################################################

$klifVT=0
$klifQT=0
$klifTT=0

$lt= %w{1 2 3 4 5 S T U}
$valueV={}; $valueQ={};$valueT={}
$lt.each {|t| $valueV[t]=$valueQ[t]=$valueT[t] = 1 }



susp=false
suspVT=false

#suspens(120,200,"all") { |s| susp=s }
suspens(20,160,"VT/QT") { |s| suspVT=s }

Thread.new { loop {
	ran=rand(0..20)
	unless susp 
	 $valueVT=(Time.now.to_i % 100) + ran
	 $valueQT=(Time.now.to_i % 10)+ ran
	 $valueTT=(Time.now.to_i % 60)+ ran
	 $lt.each { |t|
		 $valueV[t]= (suspVT ? false : $valueVT)
		 $valueQ[t]=$valueQT 
		 $valueT[t]=$valueTT
	 }
	end
	sleep(3)
} }

sleep 0.1
