**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTEGRIDAD_STOCK.
* Fecha               : 05/05/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla la integridad de los materiales
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTEGRIDAD_FORM
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
*&      Form  ARMO_TABLA_ALV (Tabla interna que se mostrara en el ALV)
*&---------------------------------------------------------------------*

FORM armo_tabla_alv .

  DATA: lv_bktxt(10) TYPE c,
        lv_tabix     TYPE sy-tabix,
        gs_mat2      TYPE  ty_mat,
        gs_mataux    TYPE ty_mat,
        lc_msg(10)   TYPE c VALUE 'SIN-DATO'.

  SORT gt_mat BY bktxt.

* incorporo los datos a la tabla final GT_MAT

  LOOP AT gt_mat REFERENCE INTO gs_mat WHERE mblnr IS NOT INITIAL.

    lv_tabix = sy-tabix.

    ADD 1 TO lv_tabix.


    READ TABLE gt_mseg INTO gs_mseg WITH KEY mblnr = gs_mat->mblnr.

    IF sy-subrc EQ 0.
      MOVE: gs_mseg-bwart TO gs_mat->bwart,
            gs_mseg-ebeln TO gs_mat->ebeln,
            gs_mseg-ebelp TO gs_mat->ebelp,
            gs_mseg-lgort TO gs_mat->lgort,
            gs_mseg-matnr TO gs_mat->matnr,
            gs_mseg-meins TO gs_mat->meins,
            gs_mseg-menge TO gs_mat->menge,
            gs_mseg-werks TO gs_mat->werks.
    ENDIF.


    READ TABLE gt_ekko INTO gs_ekko WITH KEY ebeln = gs_mat->ebeln.
    IF sy-subrc EQ 0.
      MOVE: gs_ekko-bedat TO gs_mat->bedat.
    ENDIF.


    READ TABLE gt_ekpo INTO gs_ekpo WITH KEY ebelp = gs_mat->ebelp
                                             ebeln = gs_mat->ebeln.
    IF sy-subrc EQ 0.
      MOVE: gs_ekpo-elikz TO gs_mat->elikz.
    ENDIF.
    IF gs_mat->bktxt IS INITIAL.
      gs_mat->bktxt = lc_msg.
       gs_mat->semaf = icon_yellow_light. "AMARILLO
      CONTINUE.
    ENDIF.
* Empiezo la busqueda de los Nros_doc (BKTXT) y completo con los registros faltantes

    lv_bktxt = gs_mat->bktxt.

*obtengo el siguiente registro

    READ TABLE gt_mat  INTO gs_mat2 INDEX lv_tabix.
    IF sy-subrc = 0.

      lv_bktxt = lv_bktxt + 1.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_bktxt
        IMPORTING
          output = lv_bktxt.

      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          input  = lv_bktxt
        IMPORTING
          output = lv_bktxt.
* comparo que el primer registro sea menor al obtenido
      WHILE lv_bktxt < gs_mat2-bktxt.

        CLEAR gs_mataux.

        gs_mataux-bktxt = lv_bktxt.
        gs_mataux-semaf = icon_red_light.
* agrego el registro faltante desde la
* estructura auxiliar y sumo la variable(lv_bktxt)
        APPEND gs_mataux TO gt_mat.
        lv_bktxt = lv_bktxt + 1.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_bktxt
          IMPORTING
            output = lv_bktxt.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            input  = lv_bktxt
          IMPORTING
            output = lv_bktxt.

      ENDWHILE.

    ENDIF.

    gs_mat->semaf = icon_green_light. "VERDE
    CLEAR: gs_ekko, gs_ekpo, gs_mseg.
  ENDLOOP.
  SORT gt_mat BY bktxt.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*

FORM display_data .
* LAYOUT
  CLEAR gs_layout.
  gs_layout-cwidth_opt = gc_x.
  gs_layout-zebra = gc_x.

* CATALOGO
  PERFORM get_fieldcat        CHANGING gt_fieldcat.

  CALL SCREEN 0100.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT
*&---------------------------------------------------------------------*

FORM get_fieldcat  CHANGING p_gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 1.
  gs_fieldcat-fieldname = 'SEMAF'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-icon      = 'X'.
  gs_fieldcat-scrtext_s = 'Status'.
  gs_fieldcat-scrtext_m = 'Status'.
  gs_fieldcat-scrtext_l = 'Status'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 2.
  gs_fieldcat-fieldname = 'MBLNR'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Doc. Mat.'.
  gs_fieldcat-scrtext_m = 'Documento material'.
  gs_fieldcat-scrtext_l = 'Documento de material'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 3.
  gs_fieldcat-fieldname = 'BKTXT'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Nro. Int.'.
  gs_fieldcat-scrtext_m = 'Numero integridad'.
  gs_fieldcat-scrtext_l = 'Numero de integridad'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 4.
  gs_fieldcat-fieldname = 'BWART'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Movimento'.
  gs_fieldcat-scrtext_m = 'Movimento'.
  gs_fieldcat-scrtext_l = 'Movimento'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 5.
  gs_fieldcat-fieldname = 'MATNR'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Material'.
  gs_fieldcat-scrtext_m = 'Material'.
  gs_fieldcat-scrtext_l = 'Material'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 6.
  gs_fieldcat-fieldname = 'MENGE'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Cant.'.
  gs_fieldcat-scrtext_m = 'Cantidad'.
  gs_fieldcat-scrtext_l = 'Cantidad'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 7.
  gs_fieldcat-fieldname = 'MEINS'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'UM'.
  gs_fieldcat-scrtext_m = 'UM'.
  gs_fieldcat-scrtext_l = 'UM'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 8.
  gs_fieldcat-fieldname = 'WERKS'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Centro'.
  gs_fieldcat-scrtext_m = 'Centro'.
  gs_fieldcat-scrtext_l = 'Centro'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 9.
  gs_fieldcat-fieldname = 'LGORT'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Almacen'.
  gs_fieldcat-scrtext_m = 'Almacen'.
  gs_fieldcat-scrtext_l = 'Almacen'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 10.
  gs_fieldcat-fieldname = 'BLDAT'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Fecha Doc.'.
  gs_fieldcat-scrtext_m = 'Fecha Documento'.
  gs_fieldcat-scrtext_l = 'Fecha de Documento'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 11.
  gs_fieldcat-fieldname = 'BUDAT'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Fecha Cont.'.
  gs_fieldcat-scrtext_m = 'Fecha Contabilizacion'.
  gs_fieldcat-scrtext_l = 'Fecha de Contabilizacion'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 12.
  gs_fieldcat-fieldname = 'LIFNR'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Prov.'.
  gs_fieldcat-scrtext_m = 'Proveedor'.
  gs_fieldcat-scrtext_l = 'proveedor'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 13.
  gs_fieldcat-fieldname = 'EBELN'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'O.C.'.
  gs_fieldcat-scrtext_m = 'Orden de comp.'.
  gs_fieldcat-scrtext_l = 'Orden de Compra'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 14.
  gs_fieldcat-fieldname = 'EBELP'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Posicion OC'.
  gs_fieldcat-scrtext_m = 'Posicion OC'.
  gs_fieldcat-scrtext_l = 'Posicion OC'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 15.
  gs_fieldcat-fieldname = 'BEDAT'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Fecha OC'.
  gs_fieldcat-scrtext_m = 'Fecha OC'.
  gs_fieldcat-scrtext_l = 'Fecha OC'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 16.
  gs_fieldcat-fieldname = 'ELIKZ'.
  gs_fieldcat-tabname   = 'GT_MAT'.
  gs_fieldcat-scrtext_s = 'Marca entrega OC'.
  gs_fieldcat-scrtext_m = 'Marca entrega OC'.
  gs_fieldcat-scrtext_l = 'Marca entrega final de OC'.
  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  CALL_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE call_alv OUTPUT.
  IF gro_custom_container IS INITIAL.

    IF cl_gui_alv_grid=>offline( ) IS INITIAL.
* Ejecución on line.
      CREATE OBJECT gro_custom_container
        EXPORTING
          container_name = gv_container_main.

      CREATE OBJECT gro_grid
        EXPORTING
          i_parent = gro_custom_container.

    ELSE.
* Ejecución de fondo
*      CREATE OBJECT gro_grid
*        EXPORTING
*          i_parent = gro_doc_container.
    ENDIF.

* Layout
*    CLEAR gs_layout.
*    gs_layout-cwidth_opt = gc_x.
*    gs_layout-zebra = gc_x.

* Catalogo
*    PERFORM get_fieldcat CHANGING gt_fieldcat.

* Display ALV
    CALL METHOD gro_grid->set_table_for_first_display
      EXPORTING
        i_structure_name = 'GT_MAT'
        is_layout        = gs_layout
        i_save           = 'A'
      CHANGING
        it_outtab        = gt_mat
        it_fieldcatalog  = gt_fieldcat.

  ENDIF.

ENDMODULE.