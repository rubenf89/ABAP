**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTEGRIDAD_STOCK.
* Fecha               : 05/05/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla la integridad de los materiales
* Versión             : 1.0
************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTEGRIDAD_TOP
*&---------------------------------------------------------------------*
INCLUDE <icon>.

TABLES: mkpf,
        mseg,
        ekko,
        ekpo.

*----------------------------------------------------------------------*
* Type´s
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_mat,
         semaf TYPE icon_d,
         mblnr TYPE mkpf-mblnr,
         mjahr TYPE mkpf-mjahr,
         bktxt TYPE mkpf-bktxt,
         bldat TYPE mkpf-bldat,
         budat TYPE mkpf-budat,
         xblnr TYPE mkpf-xblnr,
         bwart TYPE mseg-bwart,
         matnr TYPE mseg-matnr,
         menge TYPE mseg-menge,
         meins TYPE mseg-meins,
         werks TYPE mseg-werks,
         lgort TYPE mseg-lgort,
         bedat TYPE ekko-bedat,
         elikz TYPE ekpo-elikz,
         ebeln TYPE mseg-ebeln,
         ebelp TYPE mseg-ebelp,
       END OF ty_mat.


TYPES: BEGIN OF ty_ekko,
         bedat TYPE ekko-bedat,
         ebeln TYPE ekko-ebeln,
       END OF ty_ekko.

TYPES: BEGIN OF ty_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         elikz TYPE ekpo-elikz,
       END OF ty_ekpo.

TYPES: BEGIN OF ty_mseg,
         mblnr TYPE mseg-mblnr,
         mjahr TYPE mseg-mjahr,
         bwart TYPE mseg-bwart,
         matnr TYPE mseg-matnr,
         menge TYPE mseg-menge,
         meins TYPE mseg-meins,
         werks TYPE mseg-werks,
         lgort TYPE mseg-lgort,
         lifnr TYPE mseg-lifnr,
         ebeln TYPE mseg-ebeln,
         ebelp TYPE mseg-ebelp,
       END OF ty_mseg.


*----------------------------------------------------------------------*
* Estructuras y tablas internas
*----------------------------------------------------------------------*

DATA:
  gt_mat  TYPE TABLE OF ty_mat,
  gs_mat  TYPE REF TO   ty_mat,
  gt_mseg TYPE TABLE OF ty_mseg,
  gs_mseg TYPE          ty_mseg,
  gt_ekko TYPE TABLE OF ty_ekko,
  gs_ekko TYPE          ty_ekko,
  gt_ekpo TYPE TABLE OF ty_ekpo,
  gs_ekpo TYPE          ty_ekpo.



*----------------------------------------------------------------------*
* Data's
*----------------------------------------------------------------------*

DATA: gv_ok_code           LIKE sy-ucomm,
      gv_container_main    TYPE scrfname VALUE 'CUST0100',
      gro_grid             TYPE REF TO cl_gui_alv_grid,
      gro_custom_container TYPE REF TO cl_gui_custom_container,
      gro_doc_container    TYPE REF TO cl_gui_docking_container,
      gt_fieldcat          TYPE lvc_t_fcat,
      gs_fieldcat          TYPE lvc_s_fcat,
      gs_layout            TYPE lvc_s_layo,
      gs_variant           TYPE disvariant,
      gv_error             TYPE c.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS: gc_x TYPE c VALUE 'X'.