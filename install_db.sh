#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

. config/settings.ini

function database_exists () {
    # /!\ Will return false if psql can't list database. Edit your pg_hba.conf
    # as appropriate.
    if [ -z $1 ]
        then
        # Argument is null
        return 0
    else
        # Grep db name in the list of database
        sudo -n -u postgres -s -- psql -tAl | grep -q "^$1|"
        return $?
    fi
}


if database_exists $db_name
then
        if $drop_apps_db
            then
            echo "Suppression de la base..."
            sudo -n -u postgres -s dropdb $db_name
        else
            echo "La base de données existe et le fichier de settings indique de ne pas la supprimer."
        fi
fi        
if ! database_exists $db_name 
then
    echo "Création de la base..."
    sudo -n -u postgres -s createdb -O $user_pg $db_name
    echo "Ajout de postgis à la base"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS postgis;"
    sudo -n -u postgres -s psql -d $db_name -c "CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog; COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';"


    # Mise en place de la structure de la base et des données permettant son focntionnement avec l'application
    echo "Grant..."
    export PGPASSWORD=$admin_pg_pass;psql -h geonatdbhost -U $admin_pg -d $db_name -f data/grant.sql &> log/install_db.log
    
    echo "Création de la structure de la base..."
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/2154/synthese_2154.sql  &>> log/install_db.log
    
    echo "Décompression des fichiers du taxref..."
    cd data/inpn
    unzip TAXREF_INPN_v8.0.zip
	unzip ESPECES_REGLEMENTEES.zip
    cd ../..
    echo "Insertion  des données taxonomiques de l'inpn... (cette opération peut être longue)"
    DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
    sed -i "s#/home/synthese/geonature#${DIR}#g" data/inpn/data_inpn_v8_synthese.sql
    export PGPASSWORD=$admin_pg_pass;psql -h geonatdbhost -U $admin_pg -d $db_name  -f data/inpn/data_inpn_v8_synthese.sql &>> log/install_db.log
 
    echo "Décompression des fichiers des communes de France métropolitaine..."
    cd data/layers
    tar -xzvf layers.tar.gz
    cd ../..
    
    echo "Insertion  du référentiel géographique : communes métropolitaines... (cette opération peut être longue)"
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name  -f data/layers/communes_metropole.sql &>> log/install_db.log
    
    echo "Insertion des données des tables dictionnaires de la base..."
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/2154/data_synthese_2154.sql  &>> log/install_db.log
    
    echo "Décompression des fichiers du référentiel géographique..."
    cd data/layers
    unzip apb.zip
    unzip bios.zip
    unzip cdl.zip
    unzip cen.zip
    unzip pn.zip
    unzip pnr.zip
    unzip pnm.zip
    unzip ramsar.zip
    unzip rb.zip
    unzip ripn.zip
    unzip rnc.zip
    unzip rncfs.zip
    unzip rnn.zip
    unzip rnr.zip
    unzip sic.zip
    unzip zps.zip
    unzip zico.zip
    unzip znieff1.zip
    unzip znieff2.zip
    unzip znieff1_mer.zip
    unzip znieff2_mer.zip
    mkdir sql
    cd ../..
    
    echo "Insertion  du référentiel géographique : zones à statut de france métropolitaine..."
    echo "...Aires de protection de biotope..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/apb/apb.shp layers.l_zonesstatut > data/layers/sql/apb.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/apb.sql &>> log/install_db.log
    echo "...Réserves de biosphère"
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/bios/bios09_2013.shp layers.l_zonesstatut > data/layers/sql/bios.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/bios.sql &>> log/install_db.log
    echo "...Sites du Conservatoire du Littoral..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/cdl/cdl2013.shp layers.l_zonesstatut > data/layers/sql/cdl.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/cdl.sql &>> log/install_db.log
    echo "...SSites acquis des Conservatoires d'espaces naturels..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/cen/cen2013_09.shp layers.l_zonesstatut > data/layers/sql/cen.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/cen.sql &>> log/install_db.log
    echo "...Parcs nationaux..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/pn/pn.shp layers.l_zonesstatut > data/layers/sql/pn.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/pn.sql &>> log/install_db.log
    echo "...Parcs naturels marins..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/pnm/pnm2014_07.shp layers.l_zonesstatut > data/layers/sql/pnm.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/pnm.sql &>> log/install_db.log
    echo "...Parcs naturels régionaux..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "UTF8"  data/layers/pnr/pnr2014_10.shp layers.l_zonesstatut > data/layers/sql/pnr.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/pnr.sql &>> log/install_db.log
    echo "...Sites Ramsar..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/ramsar/ramsar2013.shp layers.l_zonesstatut > data/layers/sql/ramsar.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/ramsar.sql &>> log/install_db.log
    echo "...Réserves biologiques..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/rb/rb.shp layers.l_zonesstatut > data/layers/sql/rb.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/rb.sql &>> log/install_db.log
    echo "...Réserves intégrales de parc national..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/ripn/ripn.shp layers.l_zonesstatut > data/layers/sql/ripn.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/ripn.sql &>> log/install_db.log
    echo "...Réserves naturelles de Corse..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/rnc/rnc2010.shp layers.l_zonesstatut > data/layers/sql/rnc.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/rnc.sql &>> log/install_db.log
    echo "...Réserves naturelles de Corse..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/rncfs/rncfs_2010.shp layers.l_zonesstatut > data/layers/sql/rncfs.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/rncfs.sql &>> log/install_db.log
    echo "...Réserves naturelles nationales..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "UTF8"  data/layers/rnn/rnn.shp layers.l_zonesstatut > data/layers/sql/rnn.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/rnn.sql &>> log/install_db.log
    echo "...Réserves naturelles régionales..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/rnr/rnr.shp layers.l_zonesstatut > data/layers/sql/rnr.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/rnr.sql &>> log/install_db.log
    echo "...Natura 2000 Sites d'importance communautaire..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/sic/sic1409.shp layers.l_zonesstatut > data/layers/sql/sic.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/sic.sql &>> log/install_db.log
    echo "...Natura 2000 Zones de protection spéciales..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/zps/zps1409.shp layers.l_zonesstatut > data/layers/sql/zps.sql
    echo "...Zone d'importance pour la conservation des oiseaux..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/zico/zico.shp layers.l_zonesstatut > data/layers/sql/zico.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/zico.sql &>> log/install_db.log
    echo "...ZNIEFF 1 continentales..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/znieff1/znieff1.shp layers.l_zonesstatut > data/layers/sql/znieff1.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/znieff1.sql &>> log/install_db.log
    echo "...ZNIEFF 2 continentales..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/znieff2/znieff2.shp layers.l_zonesstatut > data/layers/sql/znieff2.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/znieff2.sql &>> log/install_db.log
    echo "...ZNIEFF 1 mer..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/znieff1_mer/znieff1_mer.shp layers.l_zonesstatut > data/layers/sql/znieff1_mer.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/znieff1_mer.sql &>> log/install_db.log
    echo "...ZNIEFF 2 mer..."
    sudo -n -u postgres -s shp2pgsql -s 2154 -a -g the_geom -W "LATIN1"  data/layers/znieff2_mer/znieff2_mer.shp layers.l_zonesstatut > data/layers/sql/znieff2_mer.sql
    export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name -f data/layers/sql/znieff2_mer.sql &>> log/install_db.log
    #export PGPASSWORD=$user_pg_pass;psql -h geonatdbhost -U $user_pg -d $db_name  -f data/layers/zonesstatut.sql &>> log/install_db.log
    
    echo "Insertion d'un jeu de données test dans les schémas contactfaune et contactinv de la base"
    export PGPASSWORD=$admin_pg_pass;psql -h geonatdbhost -U $admin_pg -d $db_name -f data/2154/data_set_synthese_2154.sql  &>> log/install_db.log

    # suppression des fichiers : on ne conserve que les fichiers compressés
    echo "nettoyage..."
    rm data/inpn/*.txt
    rm data/inpn/*.xls
    rm data/inpn/*.csv
    rm data/layers/communes_metropole.sql
    # rm data/layers/zonesstatut.sql
    rm -R data/layers/apb
    rm -R data/layers/bios
    rm -R data/layers/cdl
    rm -R data/layers/cen
    rm -R data/layers/pn
    rm -R data/layers/pnr
    rm -R data/layers/pnm
    rm -R data/layers/ramsar
    rm -R data/layers/rb
    rm -R data/layers/ripn
    rm -R data/layers/rnc
    rm -R data/layers/rncfs
    rm -R data/layers/rnn
    rm -R data/layers/rnr
    rm -R data/layers/sic
    rm -R data/layers/zps
    rm -R data/layers/zico
    rm -R data/layers/znieff1
    rm -R data/layers/znieff2
    rm -R data/layers/znieff1_mer
    rm -R data/layers/znieff2_mer
    rm -R data/layers/sql

fi