**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTGRD_CANT.
* Fecha               : 19/06/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla las cantidades de documentos materiales faltantes
* Versión             : 1.0
************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTGRD_CANT_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .

**************COMIENZO DE SELECT's***********
*********************************************
  SELECT mblnr
         mjahr
         bktxt
         bldat
         budat
         xblnr
     INTO CORRESPONDING FIELDS OF TABLE gt_mat
     FROM mkpf
    WHERE
          bktxt IN s_bktxt AND
          budat IN s_budat AND
          mblnr IN s_mblnr.

  IF sy-subrc EQ 0.


    SELECT
           mblnr
           mjahr
           bwart
           matnr
           menge
           meins
           werks
           lgort
           lifnr
           ebeln
           ebelp
           INTO TABLE gt_mseg
           FROM mseg
           FOR ALL ENTRIES IN gt_mat
           WHERE mblnr     EQ gt_mat-mblnr AND
                 bwart     IN s_bwart       AND
                 mjahr     EQ gt_mat-mjahr.
    IF sy-subrc EQ 0.

      SELECT
             bedat
             ebeln
            INTO TABLE gt_ekko
            FROM ekko
           FOR ALL ENTRIES IN gt_mseg
           WHERE ebeln     EQ gt_mseg-ebeln
              .



      SELECT ebeln
             ebelp
             elikz
             INTO TABLE gt_ekpo
             FROM ekpo
         FOR ALL ENTRIES IN gt_mseg
             WHERE ebelp EQ gt_mseg-ebelp AND
                   ebeln EQ gt_mseg-ebeln.

    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ARMO_TABLA_ALV
*&---------------------------------------------------------------------*
FORM armo_tabla_alv.

  DATA: lv_bktxt(10)  TYPE c,
        lv_bktxt2(10) TYPE c,
        lv_res        TYPE i,
        lv_tabix      TYPE sy-tabix,
        gs_mat2       TYPE REF TO ty_mat.


  SORT         gt_mat BY bktxt.

  LOOP AT gt_mat REFERENCE INTO gs_mat.
    lv_tabix = sy-tabix.
    ADD 1 TO lv_tabix.

    READ TABLE gt_mseg REFERENCE INTO gs_mseg WITH KEY mblnr = gs_mat->mblnr.
    IF sy-subrc EQ 0.
      MOVE: gs_mseg->bwart TO gs_mat->bwart,
            gs_mseg->ebeln TO gs_mat->ebeln,
            gs_mseg->ebelp TO gs_mat->ebelp,
            gs_mseg->lgort TO gs_mat->lgort,
            gs_mseg->matnr TO gs_mat->matnr,
            gs_mseg->meins TO gs_mat->meins,
            gs_mseg->menge TO gs_mat->menge,
            gs_mseg->werks TO gs_mat->werks,
            gs_mseg->lifnr TO gs_mat->lifnr.
    ENDIF.

    READ TABLE gt_ekko REFERENCE INTO gs_ekko WITH KEY ebeln = gs_mat->ebeln.

    IF sy-subrc EQ 0.
      MOVE: gs_ekko->bedat TO gs_mat->bedat.
    ENDIF.

    READ TABLE gt_ekpo REFERENCE INTO gs_ekpo WITH KEY ebeln = gs_mat->ebeln
                                                       ebelp = gs_mat->ebelp.
    IF sy-subrc EQ 0.
      MOVE: gs_ekpo->elikz TO gs_mat->elikz.
    ENDIF.

    lv_bktxt = gs_mat->bktxt.
    READ TABLE gt_mat REFERENCE INTO gs_mat2 INDEX lv_tabix.
    IF sy-subrc EQ 0.

      lv_bktxt2 = gs_mat2->bktxt.
      lv_res = lv_bktxt2 - lv_bktxt.

      IF lv_res NE 1.

        MOVE: lv_bktxt TO gs_mat->rngini,
              lv_bktxt2 TO gs_mat->rngfin,
              lv_res TO gs_mat->faltan.

      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*

FORM display_data .

  CALL SCREEN 0100.
ENDFORM.