**********************Documentación Principal **************************
* Nombre del programa : ZRFI_REPORTE_DEUDORES_TOP
* Fecha               : 19/02/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que detalla datos de Clientes deudores.
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRFI_REPORTE_DEUDORES_TOP
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&                      TABLES
*&---------------------------------------------------------------------*
TABLES: kna1,
        knvk.


*&---------------------------------------------------------------------*
*&                            TYPES
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_cli,
         kunnr      TYPE kunnr,              " cliente
         name1      TYPE name1_gp,           " Nombre 1
         adrnr      TYPE adrnr,
         tel_number TYPE ad_tlnmbr1,         " telefono
         zterm      TYPE dzterm,             " Condicion de pago
         pernr      TYPE pernr_d,
         gv_cob     TYPE string,             " COBRADOR
         gv_ven     TYPE string,             " VENDEDOR
         spart      TYPE spart,              " Sector / denominacion de venta
         kdgrp      TYPE kdgrp,              " Grupo de cliente
         parnr      TYPE parnr,
         namev      TYPE namev_vp,           " nombre de pila de la persona de contacto
         namec      TYPE name1_gp,           " Nomre 1 persona de contacto
         abtpa      TYPE abtei_pa,           " Departamento  cliente de Persona de contacto
         abtnr      TYPE abtnr_pa,           " Departamento de persona de conatacto (Z001/02/03)
         parau      TYPE parau,              " comentarios de persona de contacto
         smtp_addr  TYPE ad_smtpadr,         " direccion de corrreo electonico
         kunn2      TYPE kunn2,
       END OF  ty_cli,

       BEGIN OF ty_kna1,
         kunnr      TYPE kunnr,              " cliente
         name1      TYPE name1_gp,           " Nombre 1
         adrnr      TYPE adrnr,
         tel_number TYPE ad_tlnmbr1,         " telefono
         zterm      TYPE dzterm,             " Condicion de pago
         pernr      TYPE pernr_d,
         gv_cob     TYPE string,             " COBRADOR
         gv_ven     TYPE string,             " VENDEDOR
         spart      TYPE spart,              " Sector / denominacion de venta
         kdgrp      TYPE kdgrp,              " Grupo de cliente
         parnr      TYPE parnr,
         namev      TYPE namev_vp,           " nombre de pila de la persona de contacto
         namec      TYPE name1_gp,           " Nomre 1 persona de contacto
         abtpa      TYPE abtei_pa,           " Departamento  cliente de Persona de contacto
         abtnr      TYPE abtnr_pa,           " Departamento de persona de conatacto (Z001/02/03)
         parau      TYPE parau,              " comentarios de persona de contacto
         smtp_addr  TYPE ad_smtpadr,         " direccion de corrreo electonico
         kunn2      TYPE kunn2,
       END OF ty_kna1,

       BEGIN OF ty_adrc,
         addrnumber TYPE ad_addrnum,
         tel_number TYPE ad_tlnmbr1,         " telefono
       END OF ty_adrc,

       BEGIN OF ty_knb1,
         kunnr TYPE kunnr,
         zterm TYPE dzterm,             " Condicion de pago
       END OF ty_knb1,

       BEGIN OF ty_knvp,
         kunnr TYPE kunnr,
         vkorg TYPE vkorg,
         vtweg TYPE vtweg,
         spart TYPE spart,
         parvw TYPE parvw,              " validar si es ZC o VE
         kunn2 TYPE kunn2,
         pernr TYPE pernr_d,
         nachn TYPE pad_nachn,
         nachb TYPE pad_nachn,
         vorna TYPE pad_vorna,
         vornb TYPE pad_vorna,
       END OF ty_knvp,

       BEGIN OF ty_pax02,
         pernr TYPE persno,
         nachn TYPE pad_nachn,
         vorna TYPE pad_vorna,
       END OF ty_pax02,

       BEGIN OF ty_knvv,
         kunnr TYPE kunnr,
         vkorg TYPE vkorg,
         vtweg TYPE vtweg,
         spart TYPE spart,           " Sector / denominacion de venta
         kdgrp TYPE kdgrp,           "Grupo de cliente
       END OF   ty_knvv,

       BEGIN OF ty_knvk,
         parnr TYPE parnr,
         kunnr TYPE kunnr,
         namev TYPE namev_vp,           " nombre de pila de la persona de contacto
         name1 TYPE name1_gp,           " Nomre 1 persona de contacto
         abtpa TYPE abtei_pa,           " Departamento  cliente de Persona de contacto
         abtnr TYPE abtnr_pa,           " Departamento de persona de conatacto (Z001/02/03)
         parau TYPE parau,              " comentarios de persona de contacto
         prsnr type knvk-prsnr,
       END OF   ty_knvk,

       BEGIN OF ty_adr6,
         addrnumber TYPE ad_addrnum,
         persnumber type adr6-persnumber,
         smtp_addr  TYPE ad_smtpadr,    "direccion de corrreo electonico
       END OF   ty_adr6,

       BEGIN OF ty_pernr,
         pernr TYPE knvp-pernr,
       END OF ty_pernr.

*&---------------------------------------------------------------------*
*&                            DATA`s
*&---------------------------------------------------------------------*
DATA: gt_cli    TYPE TABLE OF ty_cli,
      gs_cli    TYPE          ty_cli,
      gt_kna1   TYPE TABLE OF ty_kna1,
      gs_kna1   TYPE          ty_kna1,
      gt_adrc   TYPE TABLE OF ty_adrc,
      gs_adrc   TYPE          ty_adrc,
      gt_knb1   TYPE TABLE OF ty_knb1,
      gs_knb1   TYPE          ty_knb1,
      gt_knvp   TYPE TABLE OF ty_knvp,
      gs_knvp   TYPE          ty_knvp,
      gT_pax02  TYPE TABLE OF ty_pax02,
      gS_pax02  TYPE          ty_pax02,
      gt_knvv   TYPE TABLE OF ty_knvv,
      gs_knvv   TYPE          ty_knvv,
      gt_knvk   TYPE TABLE OF ty_knvk,
      gs_knvk   TYPE          ty_knvk,
      gt_adr6   TYPE TABLE OF ty_adr6,
      gs_adr6   TYPE          ty_adr6,
      gt_pernr  TYPE TABLE OF ty_pernr,
      gs_pernr  TYPE          ty_pernr.

DATA: gr_kunn2 TYPE RANGE OF knvp-kunn2,
      gs_kunn2 like LINE OF gr_kunn2.

DATA: rg_parvw TYPE RANGE OF knvp-parvw.
      rg_parvw = VALUE #( sign = 'I' option = 'EQ' ( low = 'ZC' )
                                                   ( low = 'VE' ) ).

*&---------------------------------------------------------------------*
*&                            DATA PARA EL ALV
*&---------------------------------------------------------------------*

DATA:gt_fieldcat          TYPE           lvc_t_fcat,
     gs_fieldcat          TYPE           lvc_s_fcat,
     gv_container_main    TYPE           scrfname        VALUE 'CUST0100',
     gro_grid             TYPE REF TO    cl_gui_alv_grid,
     gro_custom_container TYPE REF TO    cl_gui_custom_container,
     gro_doc_container    TYPE REF TO    cl_gui_docking_container,
     gs_layout            TYPE           lvc_s_layo,
     gv_error             TYPE           c.

*----------------------------------------------------------------------*
* CONSTANTES                                                           *
*----------------------------------------------------------------------*
CONSTANTS: gc_x(1)  VALUE 'X',
           lv_in(1) value 'I',
           lv_eq(2) VALUE 'EQ'.