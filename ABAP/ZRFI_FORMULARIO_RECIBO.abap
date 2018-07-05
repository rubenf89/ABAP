************************************************************************
* Nombre del Programa : ZRFI_FORMULARIO_RECIBO
* Descripcion         : Programa de impresión de recibos
* Autor del Programa  : XIOMA
* Fecha               : 15/06/2015
* Orden de Transporte : DEVK900141 (8128-FI-Impresión de Recibos-v1)
************************************************************************
* 19.03.2018 - -DEVK908962  - TKT: 405301-
**********************************************************************

REPORT zrfi_formulario_recibo.

**********************************************************************
* Includes
**********************************************************************


INCLUDE znfi_formulario_recibo_top.
*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
INCLUDE znfi_formulario_recibo_sel.
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962
INCLUDE znfi_formulario_recibo_f01.

************************************************************************
* PARAMETROS DE SELECCION
************************************************************************
*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
*SELECTION-SCREEN FUNCTION KEY 1.
*SELECTION-SCREEN FUNCTION KEY 2.
*SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
*
*SELECT-OPTIONS: s_socied FOR bkpf-bukrs OBLIGATORY NO INTERVALS NO-EXTENSION,
*                s_numero FOR bkpf-belnr,
*                s_ejerci FOR bkpf-gjahr OBLIGATORY NO INTERVALS NO-EXTENSION,
*                s_fecha  FOR bkpf-budat ,
*                s_refere FOR bkpf-xblnr,
**    las sucursales válidas se encuentran en el dominio
**    del elemento de datos que define a la variable que sigue.
*                s_sucurs FOR v_sucurs,
**    las clases de documento válidas se encuentran en el dominio
**    del elemento de datos que define a la variable que sigue.
*                s_clase  FOR v_clase,
***---- INI - JPCoelho - 2016.11.14 ----**
***-- Hacer Obligatorio a Cliente, para Select a la BSAD en formulario
**                s_client FOR bseg-kunnr,
*                s_client FOR bseg-kunnr OBLIGATORY,
***---- FIN - JPCoelho - 2016.11.14 ----**
*                s_uname  FOR bkpf-usnam DEFAULT sy-uname.
*
*SELECTION-SCREEN END OF BLOCK block1.
*
*SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
*
*PARAMETERS cb_mail TYPE c AS CHECKBOX.
*
*SELECTION-SCREEN END OF BLOCK block2.
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962

************************************************************************
* Evento INITIALIZATION
************************************************************************
INITIALIZATION.
  MOVE 'Medios de Pago'(001) TO sscrfields-functxt_01.
  MOVE 'Tipo de Recibo'(002) TO sscrfields-functxt_02.

* Creo el rango de clase de documento
  PERFORM init_ranges.

* Obtengo cuentas a excluir en la seleccion de posiciones
*  PERFORM obtener_cuentas_a_excluir.

************************************************************************
* Evento AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN.

  IF sy-ucomm = 'FC01'.

    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = c_update
        view_name = c_cuentas.

  ELSEIF sy-ucomm = 'FC02'.

    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = c_update
        view_name = c_rec.

  ENDIF.

************************************************************************
* Evento START-OF-SELECTION
************************************************************************

START-OF-SELECTION.
  MOVE space TO v_imprimio.

END-OF-SELECTION.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = 'Buscando información, por favor espere...'.

*  PERFORM carga_rangos.

* formato de sucursal
*  LOOP AT s_sucurs.
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = s_sucurs-low
*      IMPORTING
*        output = s_sucurs-low.
*
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*      EXPORTING
*        input  = s_sucurs-high
*      IMPORTING
*        output = s_sucurs-high.
*
*    MODIFY s_sucurs.
*  ENDLOOP.

  CLEAR i_bkpf.
  REFRESH i_bkpf.

  PERFORM init_print_options.
*  PERFORM nombre_funcion.

* si el usuario selecciona uno o un rango de clientes
* me conviene iniciar la busqueda en bsid y bsad por que
* hay índice por este campo.
* para todas las otras selecciones da lo mismo por lo que
* inicio la búsqueda en bkpf

  DESCRIBE TABLE s_client LINES v_clientes.

  IF v_clientes EQ 0.
*    CALL FUNCTION 'CUSTOMER_READ'.
*   traigo los registros a mi tabla interna por la clave de bkpf.
    SELECT bukrs
           belnr
           gjahr
           blart
           budat
           xblnr
           brnch
           waers
    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE i_bkpf
    WHERE bukrs IN s_socied AND
          belnr IN s_numero AND
          gjahr IN s_ejerci AND
          budat IN s_fecha  AND
          xblnr IN s_refere AND
*          ( brnch IN s_sucurs AND brnch IN r_sucurs ) AND
*          ( blart IN s_clase  AND blart IN r_clase )  AND
          brnch IN s_sucurs AND
          blart IN s_clase  AND
          blart IN gr_blart AND
          stblg EQ space.   "AND
*          usnam IN s_uname.

*   agrego el valor de los campos kunnr y gsber que no están en bkpf
*   agrego el filtro koart = 'D' por solo me interesan lo registros
*   de deudores, no mayor ni proveedores.

    LOOP AT i_bkpf.

      SELECT SINGLE kunnr
                    gsber
      FROM bseg
      INTO CORRESPONDING FIELDS OF i_bkpf
      WHERE bukrs EQ i_bkpf-bukrs AND
            gjahr EQ i_bkpf-gjahr AND
            belnr EQ i_bkpf-belnr AND
            koart EQ 'D'. "AND
*        ( ( saknr NE gv_ctaaut1 AND hkont NE gv_ctaaut1 ) AND
*          ( saknr NE gv_ctaaut2 AND hkont NE gv_ctaaut2 ) ).

      MODIFY i_bkpf.

    ENDLOOP.

    SORT i_bkpf BY xblnr.
    DELETE ADJACENT DUPLICATES FROM i_bkpf.

  ELSE.

*   agrego los registros a mi tabla interna desde bsid y bsad.
    SELECT bukrs
           belnr
           gjahr
           blart
           budat
           xblnr
           kunnr
           gsber
    FROM bsid
    APPENDING CORRESPONDING FIELDS OF TABLE i_bkpf
    WHERE bukrs IN s_socied AND
          belnr IN s_numero AND
          gjahr IN s_ejerci AND
          budat IN s_fecha  AND
          xblnr IN s_refere AND
          ( blart IN s_clase AND blart IN r_clase ) AND
          blart IN gr_blart AND
          kunnr IN s_client. "AND
*        ( ( saknr NE gv_ctaaut1 AND hkont NE gv_ctaaut1 ) AND
*          ( saknr NE gv_ctaaut2 AND hkont NE gv_ctaaut2 ) ).

    SELECT bukrs
           belnr
           gjahr
           blart
           budat
           xblnr
           kunnr
           gsber
    FROM bsad
    APPENDING CORRESPONDING FIELDS OF TABLE i_bkpf
    WHERE bukrs IN s_socied AND
          belnr IN s_numero AND
          gjahr IN s_ejerci AND
          budat IN s_fecha  AND
          xblnr IN s_refere AND
          ( blart IN s_clase AND blart IN r_clase ) AND
          blart IN gr_blart AND
          kunnr IN s_client. "AND
*        ( ( saknr NE gv_ctaaut1 AND hkont NE gv_ctaaut1 ) AND
*          ( saknr NE gv_ctaaut2 AND hkont NE gv_ctaaut2 ) ).

* como traje de bsid y bsad tengo posiciones y, probablemente
* más de un registro por cabecera, ergo ordeno y elimino sobrantes.

*    SORT i_bkpf.
*    DELETE ADJACENT DUPLICATES FROM i_bkpf.

*   agrego y valido el valor de brnch que no esta en bsid y bsad
*    LOOP AT i_bkpf.
*      SELECT SINGLE brnch
*      FROM bkpf
*      INTO CORRESPONDING FIELDS OF i_bkpf
*      WHERE bukrs EQ i_bkpf-bukrs AND
*            gjahr EQ i_bkpf-gjahr AND
*            belnr EQ i_bkpf-belnr AND
*            blart IN gr_blart. "Added Xioma.
*
*      IF ( i_bkpf-brnch IN s_sucurs AND i_bkpf-brnch IN r_sucurs ) .
*        MODIFY i_bkpf.
*      ELSE.
*        DELETE i_bkpf.
*      ENDIF.
*
*    ENDLOOP.
  ENDIF.

  SORT i_bkpf BY xblnr.
  DELETE ADJACENT DUPLICATES FROM i_bkpf.

  LOOP AT i_bkpf.
    CONCATENATE 'Imprimiendo recibo' i_bkpf-belnr
      INTO v_msg_prog
      SEPARATED BY space.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = sy-index
        text       = v_msg_prog.

*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962

* si blart ne (DS o DT) entonces clear a envio x mail
    IF  i_bkpf-blart NE 'DS'  AND
        i_bkpf-blart  NE 'DT' AND
        cb_mail IS INITIAL.
      CLEAR ls_control_parameters-getotf.
    ENDIF.
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962
    PERFORM imprimir USING g_preim.

  ENDLOOP.
*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
  IF gv_enviado EQ 'X'.
    MESSAGE text-e03 TYPE 'I'.
  ENDIF.
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962

  IF v_imprimio NE 'X'.
    MESSAGE text-e01 TYPE 'I'.
  ENDIF.