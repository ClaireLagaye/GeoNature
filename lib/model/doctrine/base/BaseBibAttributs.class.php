<?php

/**
 * BaseBibAttributs
 * 
 * This class has been auto-generated by the Doctrine ORM Framework
 * 
 * @property integer $id_attribut
 * @property string $nom_attribut
 * @property string $label_attribut
 * @property string $liste_valeur_attribut
 * @property boolean $obligatoire
 * @property string $desc_attribut
 * @property string $type_attribut
 * @property Doctrine_Collection $CorTaxonAttribut
 * 
 * @method integer             getIdAttribut()            Returns the current record's "id_attribut" value
 * @method string              getNomAttribut()           Returns the current record's "nom_attribut" value
 * @method string              getLabelAttribut()         Returns the current record's "label_attribut" value
 * @method string              getListeValeurAttribut()   Returns the current record's "liste_valeur_attribut" value
 * @method boolean             getObligatoire()           Returns the current record's "obligatoire" value
 * @method string              getDescAttribut()          Returns the current record's "desc_attribut" value
 * @method string              getTypeAttribut()          Returns the current record's "type_attribut" value
 * @method Doctrine_Collection getCorTaxonAttribut()      Returns the current record's "CorTaxonAttribut" collection
 * @method BibAttributs        setIdAttribut()            Sets the current record's "id_attribut" value
 * @method BibAttributs        setNomAttribut()           Sets the current record's "nom_attribut" value
 * @method BibAttributs        setLabelAttribut()         Sets the current record's "label_attribut" value
 * @method BibAttributs        setListeValeurAttribut()   Sets the current record's "liste_valeur_attribut" value
 * @method BibAttributs        setObligatoire()           Sets the current record's "obligatoire" value
 * @method BibAttributs        setDescAttribut()          Sets the current record's "desc_attribut" value
 * @method BibAttributs        setTypeAttribut()          Sets the current record's "type_attribut" value
 * @method BibAttributs        setCorTaxonAttribut()      Sets the current record's "CorTaxonAttribut" collection
 * 
 * @package    geonature
 * @subpackage model
 * @author     Gil Deluermoz
 * @version    SVN: $Id: Builder.php 7490 2010-03-29 19:53:27Z jwage $
 */
abstract class BaseBibAttributs extends sfDoctrineRecord
{
    public function setTableDefinition()
    {
        $this->setTableName('taxonomie.bib_attributs');
        $this->hasColumn('id_attribut', 'integer', 4, array(
             'type' => 'integer',
             'primary' => true,
             'length' => 4,
             ));
        $this->hasColumn('nom_attribut', 'string', 255, array(
             'type' => 'string',
             'length' => 255,
             ));
        $this->hasColumn('label_attribut', 'string', 50, array(
             'type' => 'string',
             'length' => 50,
             ));
        $this->hasColumn('liste_valeur_attribut', 'string', null, array(
             'type' => 'string',
             'length' => '',
             ));
        $this->hasColumn('obligatoire', 'boolean', 1, array(
             'type' => 'boolean',
             'length' => 1,
             ));
        $this->hasColumn('desc_attribut', 'string', null, array(
             'type' => 'string',
             'length' => '',
             ));
        $this->hasColumn('type_attribut', 'string', 50, array(
             'type' => 'string',
             'length' => 50,
             ));
    }

    public function setUp()
    {
        parent::setUp();
        $this->hasMany('CorTaxonAttribut', array(
             'local' => 'id_attribut',
             'foreign' => 'id_attribut'));
    }
}