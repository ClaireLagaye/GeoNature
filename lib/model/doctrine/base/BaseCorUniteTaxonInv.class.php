<?php

/**
 * BaseCorUniteTaxonInv
 * 
 * This class has been auto-generated by the Doctrine ORM Framework
 * 
 * @property integer $id_taxon
 * @property integer $id_unite_geo
 * @property date $derniere_date
 * @property string $couleur
 * @property integer $nb_obs
 * @property BibTaxons $BibTaxons
 * @property LUnitesGeo $LUnitesGeo
 * @property Doctrine_Collection $VNomadeTaxonsInv
 * 
 * @method integer             getIdTaxon()          Returns the current record's "id_taxon" value
 * @method integer             getIdUniteGeo()       Returns the current record's "id_unite_geo" value
 * @method date                getDerniereDate()     Returns the current record's "derniere_date" value
 * @method string              getCouleur()          Returns the current record's "couleur" value
 * @method integer             getNbObs()            Returns the current record's "nb_obs" value
 * @method BibTaxons           getBibTaxons()        Returns the current record's "BibTaxons" value
 * @method LUnitesGeo          getLUnitesGeo()       Returns the current record's "LUnitesGeo" value
 * @method Doctrine_Collection getVNomadeTaxonsInv() Returns the current record's "VNomadeTaxonsInv" collection
 * @method CorUniteTaxonInv    setIdTaxon()          Sets the current record's "id_taxon" value
 * @method CorUniteTaxonInv    setIdUniteGeo()       Sets the current record's "id_unite_geo" value
 * @method CorUniteTaxonInv    setDerniereDate()     Sets the current record's "derniere_date" value
 * @method CorUniteTaxonInv    setCouleur()          Sets the current record's "couleur" value
 * @method CorUniteTaxonInv    setNbObs()            Sets the current record's "nb_obs" value
 * @method CorUniteTaxonInv    setBibTaxons()        Sets the current record's "BibTaxons" value
 * @method CorUniteTaxonInv    setLUnitesGeo()       Sets the current record's "LUnitesGeo" value
 * @method CorUniteTaxonInv    setVNomadeTaxonsInv() Sets the current record's "VNomadeTaxonsInv" collection
 * 
 * @package    geonature
 * @subpackage model
 * @author     Gil Deluermoz
 * @version    SVN: $Id: Builder.php 7490 2010-03-29 19:53:27Z jwage $
 */
abstract class BaseCorUniteTaxonInv extends sfDoctrineRecord
{
    public function setTableDefinition()
    {
        $this->setTableName('contactinv.cor_unite_taxon_inv');
        $this->hasColumn('id_taxon', 'integer', 4, array(
             'type' => 'integer',
             'primary' => true,
             'length' => 4,
             ));
        $this->hasColumn('id_unite_geo', 'integer', 4, array(
             'type' => 'integer',
             'notnull' => true,
             'length' => 4,
             ));
        $this->hasColumn('derniere_date', 'date', 25, array(
             'type' => 'date',
             'length' => 25,
             ));
        $this->hasColumn('couleur', 'string', 10, array(
             'type' => 'string',
             'length' => 10,
             ));
        $this->hasColumn('nb_obs', 'integer', 4, array(
             'type' => 'integer',
             'length' => 4,
             ));
    }

    public function setUp()
    {
        parent::setUp();
        $this->hasOne('BibTaxons', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));

        $this->hasOne('LUnitesGeo', array(
             'local' => 'id_unite_geo',
             'foreign' => 'id_unite_geo'));

        $this->hasMany('VNomadeTaxonsInv', array(
             'local' => 'id_taxon',
             'foreign' => 'id_taxon'));
    }
}