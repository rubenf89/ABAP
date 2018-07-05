**********************Documentación Principal **************************
* Nombre del programa : ZRFI_REPORTE_DEUDORES_FORM
* Fecha               : 19/02/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que detalla datos de Clientes deudores.
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRFI_REPORTE_DEUDORES_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  OBTENER_DATOS
*&---------------------------------------------------------------------*

FORM obtener_clientes.

  DATA:lv_cont     TYPE i.

**************COMIENZO DE SELECT's***********
****************************************************
*****TABLA CON LOS DATOS DEL NOMBRE Y CODIGO DE CLIENTE******
  SELECT
        kunnr
        name1
        adrnr
    INTO TABLE gt_kna1
    FROM kna1
    WHERE kunnr IN s_cli AND
          ktokd IN s_grcta.

  IF sy-subrc EQ 0.

****TABLAS CON LOS NUMEROS DE TELEFONOS*****
    SELECT
        addrnumber
        tel_number
         INTO TABLE gt_adrc
      FROM adrc
      FOR ALL ENTRIES IN gt_kna1
      WHERE addrnumber EQ gt_kna1-adrnr.

****TABLA CON LAS CONDICIONES DE PAGOS*****
    SELECT
       kunnr
       zterm
      INTO TABLE gt_knb1
      FROM knb1
      FOR ALL ENTRIES IN gt_kna1
      WHERE kunnr EQ  gt_kna1-kunnr.

****TABLA CON LOS DATOS DEL COBRADOR/VENDEDOR***

    SELECT
        kunnr
        vkorg
        vtweg
        spart
        parvw
        kunn2
        pernr
      INTO TABLE gt_knvp
      FROM knvp
      FOR ALL ENTRIES IN gt_kna1
      WHERE kunnr EQ gt_kna1-kunnr AND
            vkorg EQ p_orgvt      AND
            vtweg EQ p_cnldst     AND
            spart EQ p_sect       AND
            parvw in rg_parvw.

****VALIDAR DATO PERNR o KUNN2*****
    IF sy-subrc EQ 0.

      REFRESH gt_pernr.
      CLEAR gs_pernr.
      LOOP AT gt_knvp INTO gs_knvp.
        IF gs_knvp-pernr IS NOT INITIAL.
          MOVE: gs_knvp-pernr TO gs_pernr-pernr.
          APPEND gs_pernr TO gt_pernr.
          CLEAR gs_pernr.
        ENDIF.
        IF gs_knvp-kunn2 IS NOT INITIAL.
          MOVE: gs_knvp-kunn2 TO gs_pernr-pernr.
          APPEND gs_pernr TO gt_pernr.
          CLEAR gs_pernr.
        ENDIF.
        CLEAR gs_knvp.
      ENDLOOP.
      DELETE ADJACENT DUPLICATES FROM gt_pernr.


****TABLA CON NOMBRE Y APELLIDO DEL COBRADOR / VENDEDOR
      IF gt_pernr IS NOT INITIAL.
        SELECT pernr
               nachn
               vorna
          INTO TABLE gt_pax02
          FROM  pa0002
          FOR ALL ENTRIES IN gt_pernr
          WHERE pernr EQ gt_pernr-pernr.

      ENDIF.
    ENDIF.

****TABLA CON SECTOR Y GRUPO DE CLIENTES****
    SELECT
        kunnr
        vkorg
        vtweg
        spart
        kdgrp
      INTO TABLE gt_knvv
      FROM knvv
      FOR ALL ENTRIES IN gt_kna1
      WHERE kunnr EQ gt_kna1-kunnr AND
            vkorg EQ p_orgvt      AND
            vtweg EQ p_cnldst     AND
            spart EQ p_sect.

****TABLA CON LOS DATOS DE CONTACTOS***
    SELECT
        parnr
        kunnr
        namev
        name1
        abtpa
        abtnr
        parau
        prsnr
      INTO TABLE gt_knvk
      FROM knvk
      WHERE kunnr IN s_cli AND
            abtnr IN s_dto.

****TABLA CON DIRECCION DE MAIL****
    SELECT
        addrnumber
        persnumber
        smtp_addr
      INTO TABLE gt_adr6
      FROM adr6
      FOR ALL ENTRIES IN gt_kna1
      WHERE addrnumber EQ gt_kna1-adrnr.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_DATA
*&---------------------------------------------------------------------*

FORM display_data.
* LAYOUT
  CLEAR gs_layout.
  gs_layout-cwidth_opt = gc_x.
  gs_layout-zebra = gc_x.

* CATALOGO
  PERFORM get_fieldcat        CHANGING gt_fieldcat.

  CALL SCREEN 100.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCAT
*&---------------------------------------------------------------------*

FORM get_fieldcat  CHANGING p_gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 1.
  gs_fieldcat-fieldname = 'KUNNR'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Cli'.
  gs_fieldcat-scrtext_m = 'Cliente'.
  gs_fieldcat-scrtext_l = 'Cliente'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 2.
  gs_fieldcat-fieldname = 'NAME1'.
  gs_fieldcat-ref_field = 'NAME1'.
  gs_fieldcat-ref_table = 'KNA1'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Nombre1'.
  gs_fieldcat-scrtext_m = 'Nombre1'.
  gs_fieldcat-scrtext_l = 'Nombre 1'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 3.
  gs_fieldcat-fieldname = 'TEL_NUMBER'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Tel'.
  gs_fieldcat-scrtext_m = 'Telef'.
  gs_fieldcat-scrtext_l = 'Telefono'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 4.
  gs_fieldcat-fieldname = 'ZTERM'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'C. de pago'.
  gs_fieldcat-scrtext_m = 'Cond de pago'.
  gs_fieldcat-scrtext_l = 'Condición de pago'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 5.
  gs_fieldcat-fieldname = 'GV_COB'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Cob (ZC)'.
  gs_fieldcat-scrtext_m = 'Cobrador (ZC)'.
  gs_fieldcat-scrtext_l = 'Cobrador (ZC)'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 6.
  gs_fieldcat-fieldname = 'GV_VEN'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Vend (VE)'.
  gs_fieldcat-scrtext_m = 'Vnddr (VE)'.
  gs_fieldcat-scrtext_l = 'Vendedor (VE)'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 7.
  gs_fieldcat-fieldname = 'KDGRP'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Grpo de cliente'.
  gs_fieldcat-scrtext_m = 'Grupo de cliente'.
  gs_fieldcat-scrtext_l = 'Grupo de cliente - Área de ventas'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 8.
  gs_fieldcat-fieldname = 'SPART'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Sec / Denom'.
  gs_fieldcat-scrtext_m = 'Sector / Denominacion'.
  gs_fieldcat-scrtext_l = 'Sector / Denominacion - Área de ventas'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 9.
  gs_fieldcat-fieldname = 'NAMEV'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Nmbre 1 contact'.
  gs_fieldcat-scrtext_m = 'Nombre 1 persona de contact'.
  gs_fieldcat-scrtext_l = 'Nombre 1 persona de contacto'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 10.
  gs_fieldcat-fieldname = 'NAMEC'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Nmbre pila prsona cntct'.
  gs_fieldcat-scrtext_m = 'Nombre de pila  de contact'.
  gs_fieldcat-scrtext_l = 'Nombre de pila de persona de contacto'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 11.
  gs_fieldcat-fieldname = 'ABTNR'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Dpto. persona contacto'.
  gs_fieldcat-scrtext_m = 'Dpto. de persona de contacto'.
  gs_fieldcat-scrtext_l = 'Dpto. de persona de contacto (Z001,Z002,Z003)'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 12.
  gs_fieldcat-fieldname = 'ABTPA'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Dpto. cliente contacto'.
  gs_fieldcat-scrtext_m = 'Dpto. de cliente de contacto'.
  gs_fieldcat-scrtext_l = 'Dpto. cliente de persona de contacto'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 13.
  gs_fieldcat-fieldname = 'PARAU'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Comentarios'.
  gs_fieldcat-scrtext_m = 'Comentarios de pers contact'.
  gs_fieldcat-scrtext_l = 'Comentarios de persona contacto'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-col_pos   = 14.
  gs_fieldcat-fieldname = 'SMTP_ADDR'.
  gs_fieldcat-tabname   = 'GT_CLI'.
  gs_fieldcat-scrtext_s = 'Correo persona contacto'.
  gs_fieldcat-scrtext_m = 'Dir. Correo persona contacto'.
  gs_fieldcat-scrtext_l = 'Dirección de correo electronico de la persona de contacto'.
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
        i_structure_name = 'GT_CLI'
        is_layout        = gs_layout
        i_save           = 'A'
      CHANGING
        it_outtab        = gt_cli
        it_fieldcatalog  = gt_fieldcat.

  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Form  ARMO_TABLA_ALV
*&---------------------------------------------------------------------*
FORM armo_tabla_alv .

  LOOP AT gt_kna1 INTO gs_kna1.
    CLEAR gs_cli.
*-----INCORPORO LOS DATOS ADCIONALES A LA TABLA PRINCIPAL

    MOVE gs_kna1 TO gs_cli.

*ADRC
    READ TABLE gt_adrc INTO gs_adrc WITH KEY addrnumber = gs_kna1-adrnr.
    IF  sy-subrc EQ 0.
      MOVE: gs_adrc-tel_number      TO gs_cli-tel_number.
    ENDIF.
*KNB1
    READ TABLE gt_knb1 INTO gs_knb1 WITH KEY kunnr = gs_kna1-kunnr.
    IF  sy-subrc EQ 0.
      MOVE: gs_knb1-zterm   TO gs_cli-zterm.
    ENDIF.
*KNVP

    LOOP AT gt_knvp INTO gs_knvp WHERE kunnr = gs_kna1-kunnr.
*    READ TABLE gt_knvp INTO gs_knvp WITH KEY kunnr = gs_kna1-kunnr.
*      IF  sy-subrc EQ 0.
*        if gs_knvp-pernr is INITIAL.
      READ TABLE gt_pax02 INTO gs_pax02 WITH KEY  pernr = gs_knvp-pernr.           "GT_PAX02
      IF sy-subrc EQ 0 AND gs_knvp-pernr IS NOT INITIAL.

* INGRESO POR EL CAMPO PRNR.
        IF gs_knvp-parvw EQ 'ZC'.

***   CASO "ZC"
          MOVE: gs_pax02-nachn TO gs_knvp-nachn,
                gs_pax02-vorna TO gs_knvp-vorna.
          CONCATENATE gs_knvp-nachn gs_knvp-vorna INTO gs_cli-gv_cob SEPARATED BY space.
          CLEAR gs_knvp-pernr.
        ELSE.
*     CASO "VE"
          MOVE: gs_pax02-nachn TO gs_knvp-nachn,
                gs_pax02-vorna TO gs_knvp-vorna.
          CONCATENATE gs_knvp-nachn gs_knvp-vorna INTO gs_cli-gv_ven SEPARATED BY space.
          CLEAR: gs_knvp-nachn,
                 gs_knvp-vorna.
        ENDIF.
      ELSE.
* SI NO EXISTE PRNR INGRESO POR KUNN2.

        IF sy-subrc NE 0.
          READ TABLE gt_pax02 INTO gs_pax02 WITH KEY  pernr = gs_knvp-kunn2.
***    CASO "ZC"
          IF gs_knvp-parvw EQ 'ZC'.

            MOVE: gs_pax02-nachn TO gs_knvp-nachn,
                  gs_pax02-vorna TO gs_knvp-vorna.
            CONCATENATE gs_knvp-nachn gs_knvp-vorna INTO gs_cli-gv_cob SEPARATED BY space.
          ELSE.
***    CASO "VE"
            MOVE: gs_pax02-nachn TO gs_knvp-nachn,
                  gs_pax02-vorna TO gs_knvp-vorna.
            CONCATENATE gs_knvp-nachn gs_knvp-vorna INTO gs_cli-gv_ven SEPARATED BY space.
          ENDIF.
        ENDIF.
*        ENDIF.
      ENDIF.
    ENDLOOP.
*KNVV
    READ TABLE gt_knvv INTO gs_knvv WITH KEY kunnr = gs_kna1-kunnr.
    IF  sy-subrc EQ 0.
      MOVE: gs_knvv-kdgrp      TO gs_cli-kdgrp,
            gs_knvv-spart      TO gs_cli-spart.
    ENDIF.

*KNVK y ADR6
    LOOP AT gt_knvk INTO gs_knvk  WHERE  kunnr = gs_kna1-kunnr.
      READ TABLE gt_adr6 INTO gs_adr6 WITH KEY addrnumber = gs_kna1-adrnr
                                               persnumber = gs_knvk-prsnr.

      MOVE: gs_knvk-name1            TO gs_cli-namec,
            gs_knvk-namev            TO gs_cli-namev,
            gs_knvk-abtnr            TO gs_cli-abtnr,
            gs_knvk-abtpa            TO gs_cli-abtpa,
            gs_knvk-parau            TO gs_cli-parau.

      MOVE gs_adr6-smtp_addr         TO gs_cli-smtp_addr.
      APPEND gs_cli                  TO gt_cli.
      CLEAR: gs_knvk, gs_adr6.

    ENDLOOP.

    IF sy-subrc NE 0 AND
      NOT gs_cli IS INITIAL.
      APPEND gs_cli TO gt_cli.
    ENDIF.
  ENDLOOP.



ENDFORM.