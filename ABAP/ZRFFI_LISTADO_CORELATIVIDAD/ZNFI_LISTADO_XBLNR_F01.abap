************************************************************************
*                           Procedimientos                             *
************************************************************************
*&---------------------------------------------------------------------*
*&      Form  GET_DATASET
*&---------------------------------------------------------------------*
FORM get_dataset USING VALUE(ip_dataset) TYPE rgsbm-shortname
                    CHANGING er_blart    TYPE ty_r_blart.

  DATA: lv_setid TYPE sethier-setid,
        lt_rgsbv TYPE TABLE OF rgsbv.

  FIELD-SYMBOLS: <lfs_rgsbv> TYPE rgsbv,
                 <lfs_blart> LIKE LINE OF er_blart.

  REFRESH: er_blart[].

  CHECK: ip_dataset IS NOT INITIAL.
**********************************************************************
  CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
    EXPORTING
      shortname                = ip_dataset
    IMPORTING
      new_setid                = lv_setid
    EXCEPTIONS
      no_set_found             = 1
      no_set_picked_from_popup = 2
      wrong_class              = 3
      wrong_subclass           = 4
      table_field_not_found    = 5
      fields_dont_match        = 6
      set_is_empty             = 7
      formula_in_set           = 8
      set_is_dynamic           = 9
      OTHERS                   = 10.

  CHECK sy-subrc EQ 0.

* Recupero los valores del SET
  CALL FUNCTION 'G_SET_FETCH'
    EXPORTING
      setnr           = lv_setid
    TABLES
      set_lines_basic = lt_rgsbv[]
    EXCEPTIONS
      no_authority    = 1
      set_is_broken   = 2
      set_not_found   = 3
      OTHERS          = 4.

* Armo el rango de 'Grupo de cuentas deudor'.
  IF lt_rgsbv[] IS NOT INITIAL.
    LOOP AT lt_rgsbv[] ASSIGNING <lfs_rgsbv>.
      APPEND INITIAL LINE TO er_blart[] ASSIGNING <lfs_blart>.
      <lfs_blart>-sign   = 'I'.
      <lfs_blart>-option = 'EQ'.
      <lfs_blart>-low    = <lfs_rgsbv>-from.
      <lfs_blart>-high   = <lfs_rgsbv>-to.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data USING ir_blart TYPE ty_r_blart
           CHANGING et_bkpf TYPE ty_t_bkpf.

  DATA: ls_bkpf       TYPE ty_s_bkpf,
        ls_saltos     TYPE ty_s_saltos,
        lv_char4(4),
        lv_salto(8)   TYPE c,
        lv_xblnr(14)  TYPE c,
        lv_dif(8)     TYPE c,
*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950

        lv_pto_vta(8) TYPE c,
        lv_j1bbranch  TYPE j_1bbrancv-name, "Nombre de la sucursal
        lv_nro_suc(4) TYPE c,
        lv_rngi       TYPE i,
        lv_rngf       TYPE i,
        lv_faltan     TYPE i.
*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950

  REFRESH: et_bkpf[].

  CHECK ir_blart[] IS NOT INITIAL.

  SELECT blart xblnr bldat
    FROM bkpf
    INTO TABLE et_bkpf[]
   WHERE bukrs EQ pa_bukrs AND
         belnr IN so_belnr AND
         gjahr IN so_gjahr AND
         blart IN ir_blart[] AND
         bldat IN so_bldat
    ORDER BY blart xblnr.
  IF sy-subrc EQ 0.
**---- INI - JPCoelho - 2016.11.22 ----**
    LOOP AT et_bkpf INTO ls_bkpf.
      IF ls_bkpf-blart EQ 'IV' OR ls_bkpf-blart EQ 'TQ'.
        ls_bkpf-blart = 'FC'.
      ELSEIF ls_bkpf-blart EQ 'IC'.
        ls_bkpf-blart = 'NC'.
      ENDIF.
      MODIFY et_bkpf FROM ls_bkpf.
    ENDLOOP.

    SORT et_bkpf BY blart xblnr.
**---- FIN - JPCoelho - 2016.11.22 ----**
    DELETE ADJACENT DUPLICATES FROM et_bkpf.

    IF NOT pa_sucur IS INITIAL.
      DELETE et_bkpf WHERE xblnr(5) NE pa_sucur.
    ENDIF.

*--- Busca el primer centro emisor
    READ TABLE et_bkpf INTO ls_bkpf INDEX 1.
    lv_char4 = ls_bkpf-xblnr(4).


    LOOP AT et_bkpf INTO ls_bkpf.
*--- salto por centro emisor
      IF lv_char4(4) NE ls_bkpf-xblnr(4).

        lv_char4 = ls_bkpf-xblnr(4).
        lv_salto = ls_bkpf-xblnr+5(8).

        ADD 1 TO lv_salto.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_salto
          IMPORTING
            output = lv_salto.

        CONTINUE.

      ENDIF.

      lv_xblnr = ls_bkpf-xblnr.

*--- inicializo el contador (primer registro)
      AT FIRST.

        lv_salto = lv_xblnr+5(8).


      ENDAT.

*--- inicializo el contador (5to caracter)
      AT NEW xblnr+4(1).

        lv_salto = lv_xblnr+5(8).

      ENDAT.

      CLEAR lv_dif.

*--- si se produce salto paso todo a tabla interna t_bkpfsalto
      IF lv_salto NE ls_bkpf-xblnr+5(8).

        CLEAR ls_saltos.
        CLEAR lv_dif.

        ls_saltos-blart = ls_bkpf-blart.
        CONCATENATE ls_bkpf-xblnr(5)
                    lv_salto
               INTO ls_saltos-xblnra.
*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950
        ls_saltos-cmpini = ls_saltos-xblnra+5(8).
*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950
        lv_dif = ls_bkpf-xblnr+5(8) - 1.
*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950
        lv_rngf = lv_dif.
*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_dif
          IMPORTING
            output = lv_dif.

*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950

        ls_saltos-letra = ls_bkpf-xblnr+4(1).

        SELECT SINGLE name
        FROM j_1bbranch
        INTO  lv_j1bbranch
        WHERE branch EQ lv_pto_vta.
        IF sy-subrc EQ 0.
          MOVE: lv_pto_vta TO ls_saltos-ptovta,
                lv_j1bbranch TO ls_saltos-name,
                ls_bkpf-bldat TO ls_saltos-bldat.
        ELSE.
*       no encuentro la sucursal para es PV
          ls_saltos-name = 'N/A'.
        ENDIF.

*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950
        IF lv_dif NE ls_saltos-xblnra+5(8).

          CONCATENATE ls_bkpf-xblnr(5)
                      lv_dif
                 INTO ls_saltos-xblnrb.
*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950
          ls_saltos-cmpfin = ls_saltos-xblnrb+5(8).
          MOVE ls_bkpf-bldat TO ls_saltos-bldat.
          lv_pto_vta = ls_bkpf-xblnr(4).

          SELECT SINGLE name
            FROM j_1bbranch
            INTO  lv_j1bbranch
            WHERE branch EQ lv_pto_vta.

          IF sy-subrc EQ 0.
            MOVE: lv_pto_vta TO ls_saltos-ptovta,
                  lv_j1bbranch TO ls_saltos-name.
          ELSE.
*         no encuentro la sucursal para es PV
            ls_saltos-name = 'N/A'.
          ENDIF.

*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950

        ENDIF.
        ls_saltos-letra = ls_bkpf-xblnr+4(1).
        ls_saltos-faltan = ( lv_rngf - ls_saltos-cmpini ) + 1.
**---- INI - JPCoelho - 2016.11.22 ----**
*        MOVE ls_bkpf-xblnr(4) TO ls_saltos-emisor.
**---- FIN - JPCoelho - 2016.11.22 ----**

        APPEND ls_saltos TO gt_saltos.

        lv_salto = ls_bkpf-xblnr+5(8).

      ENDIF.

*--- inicializo el contador (centro emisor)
      AT NEW xblnr(4).

        lv_salto = lv_xblnr+5(8).

      ENDAT.

*--- suma una posicion
      ADD 1 TO lv_salto.
*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950

      lv_rngi = lv_salto.
*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = lv_salto
        IMPORTING
          output = lv_salto.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_BKPF[]  text
*----------------------------------------------------------------------*
FORM display_alv.

  DATA lt_fieldcat  TYPE          slis_t_fieldcat_alv.
  DATA: ls_fieldcat LIKE LINE OF  lt_fieldcat,
        ls_layout   TYPE slis_layout_alv.

  ls_layout-colwidth_optimize = 'X'.

*[ BEGIN OF MODIF]-------------------------------------F12510-25.04.2018-OT:DEVK908950

  ls_fieldcat-fieldname = 'BLDAT'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'BLDAT'.
  ls_fieldcat-seltext_m = 'Fecha'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'NAME'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'NAME'.
  ls_fieldcat-seltext_m = 'Sucursal'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'BLART'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'BLART'.
  ls_fieldcat-seltext_m = 'Tipo'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'PTOVTA'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'PTOVTA'.
  ls_fieldcat-seltext_m = 'Punto De Venta'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'LETRA'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'LETRA'.
  ls_fieldcat-seltext_m = 'Letra'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'CMPINI'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'CMPINI'.
  ls_fieldcat-seltext_m = 'Rango comp inicial'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'CMPFIN'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'CMPFIN'.
  ls_fieldcat-seltext_m = 'Rango comp final'.
  APPEND ls_fieldcat TO lt_fieldcat.

  ls_fieldcat-fieldname = 'FALTAN'.
  ls_fieldcat-tabname   = 'GT_SALTOS'.
  ls_fieldcat-ref_fieldname  = 'FALTAN'.
  ls_fieldcat-seltext_m = 'Faltantes'.
  APPEND ls_fieldcat TO lt_fieldcat.


*  ls_fieldcat-fieldname = 'BLART'.
*  ls_fieldcat-tabname   = 'GT_SALTOS'.
*  ls_fieldcat-ref_fieldname  = 'BLART'.
***---- INI - JPCoelho - 2016.11.22 ----**
**  ls_fieldcat-seltext_m = 'Cl.Doc.'.
*  ls_fieldcat-seltext_m = 'Tip.Cpbte'.
***---- FIN - JPCoelho - 2016.11.22 ----**
*  APPEND ls_fieldcat TO lt_fieldcat.


*  ls_fieldcat-fieldname = 'XBLNRA'.
*  ls_fieldcat-tabname   = 'GT_SALTOS'.
*  ls_fieldcat-ref_fieldname  = 'XBLNR'.
*  ls_fieldcat-seltext_m = 'Nro.Doc.Ref. Desde'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
*  ls_fieldcat-fieldname = 'XBLNRB'.
*  ls_fieldcat-tabname   = 'GT_SALTOS'.
*  ls_fieldcat-ref_fieldname  = 'XBLNR'.
*  ls_fieldcat-seltext_m = 'Nro.Doc.Ref. Hasta'.
*  APPEND ls_fieldcat TO lt_fieldcat.
*
*  ls_fieldcat-fieldname = 'NAME'.
*  ls_fieldcat-tabname   = 'GT_SALTOS'.
*  ls_fieldcat-seltext_m = 'Sucursal'.
*  APPEND ls_fieldcat TO lt_fieldcat.

*[ END OF MODIF]---------------------------------------F12510-25.04.2018-OT:DEVK908950

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = ls_layout
      it_fieldcat        = lt_fieldcat
    TABLES
      t_outtab           = gt_saltos
    EXCEPTIONS
      OTHERS             = 0.

ENDFORM.