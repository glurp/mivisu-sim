2w
==
Exemple of ruby connector TCP/IP, which transport some binary data.
All coded with  (internal) DSL, Ruby based.

TODO: include a GUI, with gui DSL of cource :)

Presentation
============

Simule le comportement d'un connecteur SSIL V2 de mivisu.
accessoirement, fournit un client SSIL 'generique'.

Fonctions :
* emission mesures, toutes les 20 secondes 
* reception login
* TODO emission etat eqp ( ETAT_SYS...)

Usage:
```
> ruby rad.rb 2200   config.rb process.rb  # lance un serveur SSIL sur localhost:2200
> ruby client.rb localhost 2200 # lance un client SSIL generique, pour tester le simulateur...
```
Sources associées:

* config.rb : represent un script qui doit creer la variable $conf, contenant la config à simuler.
 on trouvera en exemple miniconf.rb et config_from_saia.rb
* process.rb : doit lancer un thread qui agira sur des varables globale $value... referencées dans la config
  on trouve en exemple : process.rb , process_manque_mesure.rb, process_mesures.nomove.rb



Prerequis
==========

installer ruby 2.3 ou superieur.

installer les dependances :
> gem install bindata minitcp

**Bindata** : definie un DSL permettant de creer des classes Codeur/Decodeur de trames binaire : voir
 https://github.com/dmendel/bindata/wiki

**Minitcp**:  DSL pour faire du TCP : voir  https://github.com/glurp/minitcp

Fichiers
========

* rad.rb    :	 serveur SSIL, emission mesure RAD ( QTV ) pour un ensemble de station/capteurs
* model.rb  :  class codec des trames SSIL mivisu, basé sur bindata, auto-test integré
* config-from-saia.rb :  extraction d'une config RRTDB saia (scada) pour generer la config a simuler
* client.rb :	 client SSIL, print tous ce qui passe (pas de login...)

* config*.rb
* process*.rb


License
======

The MIT License
Copyright (c) 2019 Regis d'Aubarede,
