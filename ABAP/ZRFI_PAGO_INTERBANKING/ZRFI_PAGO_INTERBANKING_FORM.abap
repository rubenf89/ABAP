*&---------------------------------------------------------------------*
*&  Include           ZRFI_PAGO_INTERBANKING_FORM
*&---------------------------------------------------------------------*
**********************************************************************
*&---------------------------------------------------------------------*
*&      Form  GET_DATA_REGUH
*&---------------------------------------------------------------------*

FORM get_data_reguh .

  SELECT
      zbnkn
      laufd
      xvorl
      zbukr
      ubnkl
      INTO CORRESPONDING FIELDS OF TABLE gt_cabe
      FROM reguh
    WHERE laufd EQ f110v-laufd AND
          laufi EQ f110v-laufi.

  IF sy-subrc EQ 0.

    SELECT
      zbnkn
      rwbtr
      vblnr
      stcd1
     INTO CORRESPONDING FIELDS OF TABLE gt_deta
     FROM reguh
     WHERE  laufd EQ f110v-laufd AND
            laufi EQ f110v-laufi.

    IF sy-subrc EQ 0.
      SELECT
         bankl
         brnch
         INTO TABLE gt_bnka
         FROM bnka
         FOR ALL ENTRIES IN gt_cabe
         WHERE bankl EQ gt_cabe-ubnkl.

      SELECT
         bankn
         koinh
         INTO TABLE gt_lfbk
         FROM lfbk
         FOR ALL ENTRIES IN gt_cabe
         WHERE bankn EQ gt_cabe-zbnkn.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  ARMAR_REGISTRO
*&---------------------------------------------------------------------*

FORM armar_registro .
  DATA: lv_rwbtr(15) TYPE c,
        lv_lineac    TYPE string,
        lv_linead    TYPE string,
        lv_cont(8)   TYPE c.

  CLEAR gt_final.

  LOOP AT gt_cabe INTO gs_cabeo WHERE xvorl IS INITIAL.



************ARMO LINEA CABACERA *U*
    READ TABLE gt_cabe INTO gs_cabe WITH KEY zbnkn = gs_cabeo-zbnkn.
    IF sy-subrc = 0.
*Obtengo el rango y se lo sumo a la cabecera
      CALL FUNCTION 'NUMBER_GET_NEXT'
        EXPORTING
          nr_range_nr = '01'
          object      = 'ZFI_F110'
        IMPORTING
          number      = lv_cont.

      MOVE:
          '*U*'   TO gs_cabeo-gcn_treg,
          'D'     TO gs_cabeo-gc_deb,
          'N'     TO gs_cabeo-gcn_mc,
          '000'   TO gs_cabeo-gc_000,
          '00'    TO gs_cabeo-gc_00.
****completo con los espacios en blanco solicitados para cada variable
      DO 61 TIMES.
        CONCATENATE ' '  gs_cabeo-gc_61 INTO gs_cabeo-gc_61.
      ENDDO.

      DO 123 TIMES.
        CONCATENATE ' '  gs_cabeo-gc_char2 INTO gs_cabeo-gc_char2.
      ENDDO.

      gs_cabeo-gv_char = lv_cont.

      READ TABLE gt_bnka INTO gs_bnka WITH KEY bankl = gs_cabeo-ubnkl.
      IF sy-subrc EQ 0.
        MOVE:
             gs_bnka-brnch TO gs_cabeo-brnch.
      ENDIF.

**se da formato la fecha segun lo requerido
      CONCATENATE gs_cabeo-laufd+4(2) gs_cabeo-laufd+6(2) gs_cabeo-laufd+2(2) INTO gs_cabeo-laufd_b SEPARATED BY '/'.

**Concateno todas las variables en una sola linea

      CONCATENATE gs_cabeo-gcn_treg gs_cabeo-brnch gs_cabeo-gc_deb gs_cabeo-laufd gs_cabeo-gcn_mc gs_cabeo-gc_61 gs_cabeo-gc_000
                  gs_cabeo-gc_00 gs_cabeo-laufd_b gs_cabeo-gv_char gs_cabeo-gc_char2
             INTO
                  lv_lineac.

* agrego a tabla como posicion de cabecera
      MOVE lv_lineac  TO gs_final-gv_linea.
      APPEND gs_final TO gt_final.

**************************ARMO LA LINEA DETALLE *M*
      READ TABLE gt_deta INTO gs_deta WITH KEY zbnkn = gs_cabeo-zbnkn.
      IF sy-subrc EQ 0.
        MOVE:
            '*M*'                                                        TO gs_deta-gc_treg,
            'FA'                                                         TO gs_deta-gc_fa,
            '00000000'                                                   TO gs_deta-gc_impnc.

*****completo con los espacios en blanco solicitados para cada variable
        DO 60 TIMES.
          CONCATENATE ' '  gs_deta-gc_60 INTO gs_deta-gc_60.
        ENDDO.
        DO 12 TIMES.
          CONCATENATE ' '  gs_deta-gc_ndc INTO gs_deta-gc_ndc.
        ENDDO.
        DO 2 TIMES.
          CONCATENATE ' ' gs_deta-gc_top INTO gs_deta-gc_top.
        ENDDO.
        DO 14 TIMES.
          CONCATENATE ' '  gs_deta-gc_cdc INTO gs_deta-gc_cdc.
        ENDDO.
        DO 2 TIMES.
          CONCATENATE ' '  gs_deta-gc_tr INTO gs_deta-gc_tr.
        ENDDO.
        DO 10 TIMES.
          CONCATENATE ' '  gs_deta-gc_ttr INTO gs_deta-gc_ttr.
        ENDDO.
        DO 12 TIMES.
          CONCATENATE ' '  gs_deta-gc_nnc INTO gs_deta-gc_nnc.
        ENDDO.
        DO 51 TIMES.
          CONCATENATE ' '  gs_deta-gc_esp INTO gs_deta-gc_esp.
        ENDDO.

***Paso el importe a positivo y le doy el formato requerido en la EF
        lv_rwbtr = gs_deta-rwbtr.

        lv_rwbtr = lv_rwbtr * -1.

        REPLACE ALL OCCURRENCES OF '.' IN lv_rwbtr WITH space.
        REPLACE ALL OCCURRENCES OF ',' IN lv_rwbtr WITH space.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_rwbtr
          IMPORTING
            output = lv_rwbtr.

        MOVE lv_rwbtr TO gs_deta-rwbtr2.

***Incorporo el CBU al detalle
        READ TABLE gt_lfbk INTO gs_lfbk WITH KEY bankn = gs_cabeo-zbnkn.
        IF sy-subrc EQ 0.
          MOVE:
              gs_lfbk-koinh TO gs_deta-koinh.
        ENDIF.

*Concateno todas las variables en una sola linea y agrego a tabla como posicion de detalle

        CONCATENATE gs_deta-gc_treg gs_deta-koinh gs_deta-rwbtr2 gs_deta-gc_60 gs_deta-gc_fa gs_deta-gc_ndc gs_deta-gc_top gs_deta-vblnr
                    gs_deta-gc_cdc gs_deta-gc_tr gs_deta-gc_ttr gs_deta-gc_nnc gs_deta-gc_impnc gs_deta-stcd1 gs_deta-gc_esp
               INTO
                    lv_linead.
**Agrego la linea que contiene el detalle a la tabla final**
        MOVE lv_linead TO gs_final-gv_linea.
        APPEND gs_final TO gt_final.

      ENDIF.
    ENDIF.
    CLEAR: gs_cabeo, gs_cabe, gs_deta,gs_final.
  ENDLOOP.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  DESCARGAR_FICHERO
*&---------------------------------------------------------------------*
FORM descargar_fichero.

  DATA:         ld_filename TYPE string,
                ld_path     TYPE string,
                ld_fullpath TYPE string,
                ld_result   TYPE i,
                file        TYPE string.


  "Función para mostrar ventana para seleccionar archivo
  CALL METHOD cl_gui_frontend_services=>file_save_dialog
    EXPORTING
      window_title      = 'Guardar archivo' "Titulo del dialogo
      default_extension = 'TXT' "Extension predeterminada
      default_file_name = 'File' "Nombre predeterminado del archivo
      initial_directory = 'C:\' "Directorio inicial
    CHANGING
      filename          = ld_filename
      path              = ld_path
      fullpath          = ld_fullpath
      user_action       = ld_result.

  IF ld_result EQ 9.
    MESSAGE 'Acción cancelada por el usuario' TYPE 'I' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  file = ld_fullpath.

  "Función para descargar archivos
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = file "Nombre del archivo
      filetype                = 'ASC' "Tipo de archivo (texto)
    TABLES
      data_tab                = gt_final "Tabla interna con los datos
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.