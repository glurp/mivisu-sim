#!/usr/bin/ruby
# Copyright (c) 2019 Regis d'Aubarede, The MIT License
# encoding: ASCII-8BIT
############################################################################
#   model.rb : binding reader/writer trames Mivisu SSIL V2
############################################################################
require 'bindata' # gem install bindata


def log(*t) puts "#{Time.now} | #{"%-80s (%s)" % [t.join(" "),caller.first.to_s]}" end

class Char < BinData::Record
	string :mvalue,:length => 1
	def self.v(a) Char.new(:mvalue => a) end
end

class Header < BinData::Record
  endian :big
  char :rtype
  char :version
  uint32 :lenmessage
  uint8 :a1
  uint8 :a2
  uint8 :a3
end

############################################################################
#   Decomposition message Relecture
############################################################################

class Mes < BinData::Record
    endian :big
	float :mvalue
	uint8  :klif
end
class BlockMes < BinData::Record
    endian :big
	string	:date,:length=>25, :trim_padding => true
	uint32  :periode
	uint16  :len_repere
	string  :repere,:length => :len_repere 
	uint16  :len_type_mesure
	string  :type_mes,:length => :len_type_mesure , :trim_padding => true
	uint16  :len_values
	array   :bmvalues,:type => :mes, :initial_length => :len_values
end
class BlockEqp < BinData::Record
    endian :big
	string	:id,:length=>16, :trim_padding => true
	uint16	:nbbloc_mes
	array   :mess, :type => :block_mes, :initial_length => :nbbloc_mes
end

class RelectureMessage < BinData::Record
    endian :big
	uint16	:nbbloc_eqp
	array   :eqps, :type => :block_eqp, :initial_length => :nbbloc_eqp
	def get_binary_size()
      io=StringIO.new ; 
	  self.write(io) ;
	  io.string.size
	end
end

def make_relecture_one_mesure(id_eqp, date, periode, repere, value, klif)
 sdate=Time.now.strftime("%Y/%m/%d %H:%M:%S")
 RelectureMessage.new( nbbloc_eqp: 1 , eqps: [
    BlockEqp.new(id: id_eqp,nbbloc_mes:1,mess:[
      BlockMes.new(
	    date: sdate, periode: periode, len_repere: repere.size, repere: repere, 
		len_type_mesure: 0,type_mes: "",len_values: 1, bmvalues: [Mes.new(mvalue:value,klif:11)]
	  )
    ])
  ])
end
def make_relecture_mesures(id_eqp, date, values=[["0/00/00",1,0]])
 sdate=Time.now.strftime("%d/%m/%Y %H:%M:%S")
 periode=20
 bm=values.select {|(repere,value,klif)| value }.map {|(repere,value,klif)|
	BlockMes.new(
	  date: sdate, periode: periode, len_repere: repere.size, repere: repere, 
	  len_type_mesure: 0,type_mes: "",
	  len_values: 1, bmvalues: [Mes.new(mvalue:value,klif: klif)] ) 
 }
 puts "Nombre de mesure= #{bm.size}"
 puts values.inspect if values.size<10
 RelectureMessage.new( nbbloc_eqp: 1 , eqps: [ BlockEqp.new(id: id_eqp,nbbloc_mes:bm.size,mess:bm) ])
end


class ConpteRenduFinCycle< BinData::Record
  endian :big
  uint32 :periode
  def get_binary_size()
      io=StringIO.new ; 
	  self.write(io) ;
	  io.string.size
  end
end

############################################################################
#   Compte rendue technique
############################################################################

class CompteRenduEtatTechnique < BinData::Record
  endian :big
  uint16	:nbbloc_eqp
  array   :eqps,  :initial_length => :nbbloc_eqp do
    endian :big
    string :eqp,:length => 16, :trim_padding => true
	uint16 :conf_version
	string :date,:length => 25, :trim_padding => true
	uint16 :etat_sys
	uint16 :etat_alim
	uint16 :etat_com
  end
  def get_binary_size()
      io=StringIO.new ; 
	  self.write(io) ;
	  io.string.size
  end
end

def make_relecture_etat_technique(eqp,date,etats)
  sdate=Time.now.strftime("%d/%m/%Y %H:%M:%S")
  CompteRenduEtatTechnique.new(nbbloc_eqp: 1, eqps: [
    {eqp: eqp,conf_version: 1, date: sdate,etat_sys: etats[0],etat_alim:  etats[1], etat_com:  etats[2]}
  ])
end


######################################### Make/send message

def make_send_message(socket,code)
	 message=yield
	 
     io=StringIO.new
	 message.write(io) 
	 len=io.string.size
     puts "Sending #{message.class} : #{message.inspect[0..140]} ..."	 
	 Header.new(rtype: Char.v(code) , version: Char.v("2") , lenmessage: len , a1:0,a2:0,a3:0).write(socket)
	 #p message
	 #p io.string
	 socket.write(io.string)
end

if $0 == __FILE__
############################################################################
#   Auto test
############################################################################
require 'pp'

def s(c,str) 
  puts "\n>>#{"%15s" % c} : String size=#{str.size} : #{str.inspect}"
  print " ";  str.each_char.each_with_index {|a,i| size=(a.ord.to_s.size+2); print "%-#{size}d" % (i)};  puts
  p str.bytes 
  print " ";  str.each_char {|a| c=(a.ord>20 ? a : "~");print c; print " "*(3-c.ord.to_s.size ); print "  "};  puts
  $last=str
  str
end

puts "\n\n\n============== Decoding test \n\n\n"
BinData::trace_reading {   Header.read(s("Header","A2\1\0\0\000123")) }
BinData::trace_reading {   Mes.read(s("Mesure","\0\0\0\0\1")) }
BinData::trace_reading {   BlockMes.read(s("Block mesure","2000/11/11 22:33:33\0\0\0\0\0\0\0\0\0\1\0\002AB\0\001X\0\001#{$last}")) }
BinData::trace_reading {   BlockEqp.read(s("Block eqp","123456789ABCDEF0\0\001#{$last}")) }
BinData::trace_reading {   RelectureMessage.read(s("Relecture","\0\001#{$last}")) }

BinData::trace_reading {   CompteRenduEtatTechnique.read(s("Etat technique","\0\001123456789012345\0\0\00211/12/2028 11:22:33\0\0\0\0\0\0\0\1\0\1\0\1")) }

puts "\n\n\n============== Encoding test \n\n\n"

p Header.new(rtype: Char.v("A") , version: Char.v("2") , lenmessage:1 , a1:0,a2:0,a3:0)
p BlockMes.new(
  date: "2022.11.11 22:22:22", periode: 11, len_repere: 6, repere: "ABCDEF", 
  len_type_mesure: 1,type_mes: "X", len_values: 0, bmvalues: [])
  
p RelectureMessage.new( nbbloc_eqp: 1 , eqps: [BlockEqp.new(id: "e",nbbloc_mes:0,mes:[])])
p rm=RelectureMessage.new( nbbloc_eqp: 1 , eqps: [
    BlockEqp.new(id: "e",nbbloc_mes:1,mess:[
      BlockMes.new(
	    date: "2022.11.11 22:22:22", periode: 11, len_repere: 2, repere: "ABCDEF", 
		len_type_mesure: 1,type_mes: "X",len_values: 0, bmvalues: []
	  )
    ])
  ])
  
io=StringIO.new()
rm.write(io)
puts  io.string.inspect
p RelectureMessage.read(io.string)

p CompteRenduEtatTechnique.new( nbbloc_eqp: 1, eqps: [{eqp:"ABCD",conf_version: 2,date:"11/22/2019 11:22:33",etat_sys: 1,etat_alim: 2, etat_com: 1}])
p cre=CompteRenduEtatTechnique.new( nbbloc_eqp: 1, eqps: [{eqp:"ABCD",conf_version: 2,date:"11/22/2019 11:22:33",etat_sys: 1,etat_alim: 2, etat_com: 1}])
io=StringIO.new()
cre.write(io)
puts  io.string.inspect

puts "\n\n\n============== Message generators test \n\n\n"

pp make_relecture_one_mesure("Regis1", Time.now, 20, "0/QT/0000/0", 3333, 0)
pp make_relecture_one_mesure("Regis2", Time.now, 20, "0/VT/0000/0", 3333, 1)
pp make_relecture_mesures("Regis", Time.now, values=[["0/00/00",1,0]])
pp make_relecture_etat_technique("Regis",Time.now,values=[1,1,1])
end
