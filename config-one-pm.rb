###############################################################
##? Configuration d'une station X40.482T avec 3 mesures
###############################################################

$conf={
 frontal: {
	user: "LABOCOM",
	passwd: "labocom",
 },
 stations: {
   "X40.482T" => {
	  "31002988/1/VT/20/0000" => { value: '$valueVT1'  , klif: '$klifVT1' },
	  "31002988/1/QT/20/0000" => { value: '$valueQT1'  , klif: '$klifQT1' },
	  "31002988/1/TT/20/0000" => { value: '$valueTT2' , klif:  '$klifTT2' },
	}
 }
}
