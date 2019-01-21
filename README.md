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
> ruby rad.rb 2200              # lance un serveur SSIL sur localhost:2200
> ruby client.rb localhost 2200 # lance un client SSIL generique, pour tester le simulateur...
```

Prerequis
==========

installer ruby 2.3 ou superieur.

installer les dependances :
> gem install bindata
> gem install minitcp

**Bindata** : definie un DSL permettant de creer des classes Codeur/Decodeur de trames binaire : voir
 https://github.com/dmendel/bindata/wiki

**Minitcp**:  DSL pour faire du TCP : voir  https://github.com/glurp/minitcp

Fichiers
========

rad.rb    :	 serveur SSIL, emission mesure RAD ( QTV ) pour un ensemble de station/capteurs
client.rb :	 client SSIL, print tous ce qui passe (pas de login...)
model.rb  :  class codec des trames SSIL mivisu, basé sur bindata, auto-test integré
config.rb :  TODO extraction d'une config saia-miserII pour simuler tout ce qui est a configurer

Configuration
============

TODO

voir le source rad.rb

