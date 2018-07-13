**********************Documentación Principal **************************
* Nombre del programa : ZRFI_PAGO_INTERBANKING
* Fecha               : 26/06/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Genera el TXT realizado por la transaccion f110
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRFI_PAGO_INTERBANKING_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&        TYPE's
*&---------------------------------------------------------------------*

TYPES:
  BEGIN OF ty_tcab,
    gcn_treg(3)   TYPE c, "Valor fijo *U*
    zbnkn         TYPE reguh-zbnkn,
    gc_deb        TYPE c, "indicador de credito/debito
    laufd         TYPE reguh-laufd, " fecha con formatp AAAAMMDD
    gcn_mc        TYPE c, " marca de consolidacion valor 'N'
    gc_61(61)     TYPE c, "observacion del lote 61 espacios en blanco
    gc_000(3)     TYPE c, "valor constante 000
    gc_00(2)      TYPE c, "valor cosntante 00
    laufd_b       TYPE reguh-laufd, "Fecha con formato MM/DD/YY
    gv_char(8)    TYPE c,
    ubnkl         TYPE reguh-ubnkl,
    brnch         TYPE bnka-brnch,
    gc_char2(123) TYPE c, " se completa con 121 espacios en blanco
    xvorl         TYPE reguh-xvorl,
    zbukr         TYPE reguh-zbukr,
    empfg         TYPE reguh-empfg,
    vblnr         TYPE reguh-vblnr,
  END OF ty_tcab,

  BEGIN OF ty_tdet,
    gc_treg(3)  TYPE c, "Valor fijo *M* -> tipo de registro
    koinh       TYPE lfbk-koinh,
    zbnkn       TYPE reguh-zbnkn,
    rwbtr       TYPE reguh-rwbtr,
    rwbtr2(15)  TYPE c, "importe de la transferencia pasado a un char17
    gc_60(60)   TYPE c, "observacion del lote 60 espacios en blanco
    gc_fa(2)    TYPE c, "Documento a cancelar FA->factura
    gc_ndc(12)  TYPE c, "Numero de documento a cancelar -> 12 espacion en blanco
    gc_top(2)   TYPE c, "Tipo de Orden de pago
    vblnr       TYPE reguh-vblnr, "Numero de orden de pago debe tener 12 espacios.
    gc_cdc(14)  TYPE c, "Codigo de cliente -> 12 espacios en blanco + 2 en blanco que completan el campo anterior.
    gc_tr(2)    TYPE c, " Tipo de retencion -> 2 espacios en blancos
    gc_ttr(10)  TYPE c, "Total de retencion -> 10 espacios en blanco
    gc_nnc(12)  TYPE c, " Numero de la nota de credito -> 12 espacios en blanco
    gc_impnc(8) TYPE c, "Importe de la nota de credito -> 8 espacios en blanco
    stcd1       TYPE reguh-stcd1, "Numero de CUIL
    gc_esp(51)  TYPE c, "51 espacios en blanco
  END OF ty_tdet,

  BEGIN OF ty_bnka ,
    bankl TYPE bnka-bankl,
    brnch TYPE bnka-brnch,
  END OF ty_bnka,

  BEGIN OF ty_lfbk,
    bankn TYPE lfbk-bankn,
    koinh TYPE lfbk-koinh,
  END OF ty_lfbk,

  BEGIN OF ty_final,
    gv_linea TYPE string,
  END OF ty_final.



*&---------------------------------------------------------------------*
*&        DATA's
*&---------------------------------------------------------------------*
DATA:
  gs_cabeo TYPE           ty_tcab,
  gs_cabe  TYPE           ty_tcab,
  gt_cabe  TYPE TABLE OF  ty_tcab,
  gs_deta  TYPE           ty_tdet,
  gt_deta  TYPE TABLE OF  ty_tdet,
  gs_final TYPE           ty_final,
  gt_final TYPE TABLE OF  ty_final,
  gs_bnka  TYPE           ty_bnka,
  gt_bnka  TYPE TABLE OF  ty_bnka,
  gs_lfbk  TYPE           ty_lfbk,
  gt_lfbk  TYPE TABLE OF  ty_lfbk,

  p_filepc TYPE rlgrap-filename,
  p_fileu  TYPE rlgrap-filename..