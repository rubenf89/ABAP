**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTGRD_CANT.
* Fecha               : 19/06/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla las cantidades de documentos materiales faltantes
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTGRD_CANT_TOP
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Tables´s
*----------------------------------------------------------------------*
TABLES: mkpf,
        mseg,
        ekko,
        ekpo.

*----------------------------------------------------------------------*
* Type´s
*----------------------------------------------------------------------*

TYPES: BEGIN OF ty_mat,
         mblnr      TYPE mkpf-mblnr,
         mjahr      TYPE mkpf-mjahr,
         bldat      TYPE mkpf-bldat,
         budat      TYPE mkpf-budat,
         xblnr      TYPE mkpf-xblnr,
         bktxt      TYPE mkpf-bktxt,
         bwart      TYPE mseg-bwart,
         matnr      TYPE mseg-matnr,
         werks      TYPE mseg-werks,
         lgort      TYPE mseg-lgort,
         lifnr      TYPE mseg-lifnr,
         menge      TYPE mseg-menge,
         meins      TYPE mseg-meins,
         ebeln      TYPE mseg-ebeln,
         ebelp      TYPE mseg-ebelp,
         bedat      TYPE ekko-bedat,
         elikz      TYPE ekpo-elikz,
         rngini(10) TYPE c,
         rngfin(10) TYPE c,
         faltan     TYPE i,
       END OF ty_mat,

       BEGIN OF ty_mseg,
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
       END OF ty_mseg,

       BEGIN OF ty_ekko,
         bedat TYPE ekko-bedat,
         ebeln TYPE ekko-ebeln,
       END OF ty_ekko,

       BEGIN OF ty_ekpo,
         ebeln TYPE ekpo-ebeln,
         ebelp TYPE ekpo-ebelp,
         elikz TYPE ekpo-elikz,
       END OF ty_ekpo.
*----------------------------------------------------------------------*
* Estructuras y tablas internas
*----------------------------------------------------------------------*

DATA:  gt_mat  TYPE TABLE OF ty_mat,
       gt_mseg TYPE TABLE OF ty_mseg,
       gt_ekko TYPE TABLE OF ty_ekko,
       gt_ekpo TYPE TABLE OF ty_ekpo,
       gs_mat  TYPE REF TO   ty_mat,
       gs_ekpo TYPE REF TO   ty_ekpo,
       gs_mseg TYPE REF TO   ty_mseg,
       gs_ekko TYPE REF TO   ty_ekko.
*----------------------------------------------------------------------*
* Data's
*----------------------------------------------------------------------*

DATA: gv_ok_code           LIKE sy-ucomm,
      gro_table            TYPE REF TO cl_salv_table,
      gro_custom_container TYPE REF TO cl_gui_custom_container,
      gro_cx_salv          TYPE REF TO cx_salv_msg,
      gro_cx_not_found     TYPE REF TO cx_salv_not_found,
      gro_columnas         TYPE REF TO cl_salv_columns_table,
      gro_columna          TYPE REF TO cl_salv_column_table,
      gro_display          TYPE REF TO cl_salv_display_settings,
      gs_layout            TYPE lvc_s_layo,
      gv_error             TYPE c,
      gro_mensaje          TYPE string.

*----------------------------------------------------------------------*
* Constantes
*----------------------------------------------------------------------*
CONSTANTS: gc_x TYPE c VALUE 'X'.