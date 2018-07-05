*&---------------------------------------------------------------------*
*&  Include           ZNFI_FORMULARIO_RECIBO_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  carga_rangos
*&---------------------------------------------------------------------*
*FORM carga_rangos.
*
*  DATA:
*    BEGIN OF i_dd07l OCCURS 0,
*      domvalue_l LIKE dd07l-domvalue_l,
*    END OF i_dd07l.
*
** valores para sucursal
*  SELECT domvalue_l
*  FROM dd07l INTO TABLE i_dd07l
*  WHERE domname = 'ZDINCOBRNC'.
*
*  LOOP AT i_dd07l.
*    MOVE: 'EQ'               TO r_sucurs-option,
*          'I'                TO r_sucurs-sign,
*          i_dd07l-domvalue_l TO r_sucurs-low,
*          ''                 TO r_sucurs-high.
*    APPEND r_sucurs.
*  ENDLOOP.
*
*  REFRESH i_dd07l.
*  CLEAR i_dd07l.
*
*  SELECT domvalue_l
*  FROM dd07l INTO TABLE i_dd07l
*  WHERE domname = 'ZDINCOBLAR'.
*
*  LOOP AT i_dd07l.
*    MOVE: 'EQ'               TO r_clase-option,
*          'I'                TO r_clase-sign,
*          i_dd07l-domvalue_l TO r_clase-low,
*          ''                 TO r_clase-high.
*    APPEND r_sucurs.
*  ENDLOOP.
*
*ENDFORM.                    "carga_rangos

*---------------------------------------------------------------------*
*       FORM init_print_options                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM init_print_options.


* Determino (una sola vez) los parametros de impresion.
*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
  IF cb_mail IS NOT INITIAL.
    ls_control_parameters-getotf = 'X'.
*    ls_itcpo-tdpreview = abap_false.
*    ls_control_parameters-no_dialog = c_true.
*    ls_control_parameters-preview = c_false.
*    ls_output_options-tdnoprint = c_true.
*    ls_itcpo-tdimmed   = c_false.
    ls_itcpo-tdimmed   = c_true.
    ls_itcpo-tddest    = 'ZLOCAL'.
    ls_itcpo-tdpreview = abap_true.
  ELSE.
    ls_itcpo-tdimmed   = c_true.
    ls_itcpo-tddest    = 'ZLOCAL'.
    ls_itcpo-tdpreview = abap_true.


    CALL FUNCTION 'GET_TEXT_PRINT_PARAMETERS'
      EXPORTING
        options       = ls_itcpo
      IMPORTING
        newoptions    = ls_itcpo
      EXCEPTIONS
        canceled      = 1
        archive_error = 2
        device        = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962
  MOVE-CORRESPONDING ls_itcpo TO ls_output_options.
  ls_output_options-tdcopies = 2."Cantidad de copias siempre debe ser 2
  ls_control_parameters-no_dialog = c_true.

  IF ls_itcpo-tdpreview = c_true.
    ls_control_parameters-preview = c_true.
    ls_output_options-tdnoprint = c_false.
  ENDIF.


ENDFORM.                    " init_print_options

*---------------------------------------------------------------------*
*       FORM imprimir                                                 *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM imprimir USING  g_preim.

  DATA: v_copia(1),
        v_impreso(1),
        v_impresiones(1) TYPE n.
*        s_imprec LIKE zfitrecimp.

  MOVE: '' TO v_impreso,
        2 TO v_impresiones.

*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
  DATA: lv_job_output_info TYPE ssfcrescl,
        lt_otfdata         TYPE tsfotf.
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962

* BEGIN ID 001 TEDK900001 INS{
  MOVE 'ZFRFI_FORMULARIO_RECIBO' TO v_nombre_form.
* END   ID 001 TEDK900001 INS }

* obtener el nombre de la funcion
* que actualmente maneja mi reporte
  CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
    EXPORTING
      formname           = v_nombre_form
    IMPORTING
      fm_name            = v_nombre_funcion
    EXCEPTIONS
      no_form            = 1
      no_function_module = 2
      OTHERS             = 3.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.

  " Esto se debe a que siempre se debe imprimir
  "  original y duplicado sin excepcion
*  DO 2 TIMES.
*
*    CASE sy-index.
*      WHEN 1.
*        v_copia = 1.
*      WHEN 2.
*        v_copia = 2.
*    ENDCASE.

  READ TABLE gt_bseg_doc_canc WITH KEY belnr = i_bkpf-belnr INTO gs_bseg_doc_canc.

  CALL FUNCTION v_nombre_funcion
    EXPORTING
      control_parameters = ls_control_parameters
      output_options     = ls_output_options
      user_settings      = ' '
      numero             = i_bkpf-belnr
      ejercicio          = i_bkpf-gjahr
      sociedad           = i_bkpf-bukrs
      sucursal           = i_bkpf-brnch
      clase              = i_bkpf-blart
      copia              = v_copia
      cliente            = i_bkpf-kunnr
*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
    IMPORTING
      job_output_info    = lt_output_info
*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962
    EXCEPTIONS
      formatting_error   = 1
      internal_error     = 2
      send_error         = 3
      user_canceled      = 4
      OTHERS             = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ELSE.
    v_imprimio = 'X'.
*    gv_enviado = 'X'.
  ENDIF.

*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962
  IF lt_output_info-otfdata[] IS NOT INITIAL.

    lt_otfdata[] = lt_output_info-otfdata[].

    PERFORM send_mail USING  i_bkpf-kunnr
                             lt_otfdata[].

  ENDIF.
*  ENDDO.

*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962

ENDFORM.                    " imprimir

*&---------------------------------------------------------------------*
*&      Form  init_ranges
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM init_ranges.

  TYPES: ty_s_blart TYPE ztfi_impr_fact,
         ty_t_blart TYPE STANDARD TABLE OF ztfi_impr_rec.
*         ty_t_blart TYPE STANDARD TABLE OF ztfi_imp_recibo.

  DATA: lrs_blart LIKE LINE OF gr_blart,
        ls_blart  TYPE ty_s_blart,
        lt_blart  TYPE ty_t_blart.

* Tipos de documentos de FI
  SELECT blart INTO TABLE lt_blart FROM ztfi_impr_rec.
*  SELECT blart INTO TABLE lt_blart FROM ztfi_imp_recibo.

* Rango de tipos de documentos (FC/NC/ND)
  REFRESH gr_blart.

  LOOP AT lt_blart INTO ls_blart.
    CLEAR lrs_blart.
    lrs_blart-sign   = 'I'.
    lrs_blart-option = 'EQ'.
    lrs_blart-low    = ls_blart.
    APPEND lrs_blart TO gr_blart.
  ENDLOOP.

ENDFORM.                    "init_ranges


*&---------------------------------------------------------------------*
*&      Form  obtener_cuentas_a_excluir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*FORM obtener_cuentas_a_excluir.
*
*  SELECT SINGLE low FROM tvarvc INTO gv_ctaaut1
*    WHERE name = c_ctaaut1.
*
*  SELECT SINGLE low FROM tvarvc INTO gv_ctaaut2
*    WHERE name = c_ctaaut2.
*
*ENDFORM.                    "obtener_cuentas_a_excluir

*[ BEGIN OF MODIF]-------------------------------------F12510-19.04.2018-OT:DEVK908962


*&---------------------------------------------------------------------*
*&      Form  send_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM send_mail  USING    p_kunnr
                         it_otfdata TYPE tsfotf.

  CONSTANTS:
    lc_pdf_format      TYPE c LENGTH 3      VALUE 'PDF',
    lc_fvg_emisor_mail TYPE adr6-smtp_addr  VALUE 'facturacioncorporativa@fravega.com.ar',
    lc_fvg_emisor_name TYPE adr6-smtp_addr  VALUE 'Frávega'.

  TYPES: BEGIN OF ty_s_kna1,
           kunnr TYPE kna1-kunnr,
           adrnr TYPE kna1-adrnr,
         END OF ty_s_kna1,
         ty_t_kna1 TYPE STANDARD TABLE OF ty_s_kna1.

  TYPES: BEGIN OF ty_s_adr6,
           smtp_addr TYPE adr6-smtp_addr,
         END OF ty_s_adr6,
         ty_t_adr6 TYPE STANDARD TABLE OF ty_s_adr6.

  DATA: lv_filesize      TYPE i,
        lt_pdf_content   TYPE solix_tab,
        lv_pdf_content   TYPE xstring,
        lv_bin_file      TYPE xstring,
        lv_update_task   TYPE sy-subrc,
        lv_pdf_size      TYPE so_obj_len,
        lv_body_size     TYPE so_obj_len,
        lv_subject       TYPE so_obj_des,
        lv_sent_to_all   TYPE os_boolean,
        lt_body_text     TYPE bcsy_text,
        lt_adr6          TYPE ty_t_adr6,
        lt_remitente     TYPE addr3_val,
        ls_remitente     TYPE addr3_val,
        lv_remitente     TYPE adr6-smtp_addr,
*        ls_nast          TYPE ty_s_nast,
        lt_kna1          TYPE ty_t_kna1,
        lt_lines         TYPE TABLE OF tline,
        lo_send_request  TYPE REF TO cl_bcs,
        lo_document      TYPE REF TO cl_document_bcs,
        lo_recipient     TYPE REF TO cl_cam_address_bcs,
        lo_sender        TYPE REF TO cl_cam_address_bcs,
        lo_bcs_exception TYPE REF TO cx_bcs.

  FIELD-SYMBOLS: <lfs_adr6> TYPE ty_s_adr6.

  CHECK: it_otfdata[] IS NOT INITIAL.

* Convertir Formulario a PDF.
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = lc_pdf_format
    IMPORTING
      bin_filesize          = lv_filesize
      bin_file              = lv_bin_file
    TABLES
      otf                   = it_otfdata[]
      lines                 = lt_lines[]
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      err_bad_otf           = 4
      OTHERS                = 5.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.

  ENDIF.

*************************BUSCO EL REMITENTE SEGUN EL USUARIO QUE EJECUTA************

  CALL FUNCTION 'SUSR_USER_ADDRESS_READ'
    EXPORTING
      user_name              = sy-uname
*     READ_DB_DIRECTLY       = ' '
      cache_results          = 'X'
    IMPORTING
      user_address           = ls_remitente
*     USER_USR03             =
*     USER_USR21             =
    EXCEPTIONS
      user_address_not_found = 1
      OTHERS                 = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.

  SELECT SINGLE smtp_addr
    FROM adr6
    INTO lv_remitente
    WHERE addrnumber EQ ls_remitente-addrnumber OR
          persnumber EQ ls_remitente-persnumber.


****************************Busco el destinatario********
  SELECT adrnr
    FROM kna1
    INTO CORRESPONDING FIELDS OF TABLE lt_kna1[]
   WHERE kunnr EQ p_kunnr.
  CHECK lt_kna1[] IS NOT INITIAL.

  SELECT smtp_addr
    FROM adr6
    INTO TABLE lt_adr6[]
     FOR ALL ENTRIES IN lt_kna1[]
   WHERE addrnumber EQ lt_kna1-adrnr.



* Adjunto archivo PDF y envio mails.
  IF NOT lt_adr6[] IS INITIAL .
    TRY.
        lo_send_request  = cl_bcs=>create_persistent( ).
        lt_pdf_content[] = cl_document_bcs=>xstring_to_solix( lv_bin_file ).

        CONCATENATE 'Recibo' i_bkpf-xblnr INTO lv_subject SEPARATED BY space.

        PERFORM set_body CHANGING lt_body_text[].
        DESCRIBE TABLE lt_body_text LINES lv_body_size.

        " Agrego Body
        lo_document = cl_document_bcs=>create_document( i_type        = 'RAW'
                                                        i_sensitivity = 'O'
                                                        i_importance  = '1'
                                                        i_text        = lt_body_text[]
                                                        i_length      = lv_body_size
                                                        i_subject     = lv_subject ).
        TRY.
            " Adjunto PDF.
            lo_document->add_attachment( EXPORTING i_attachment_type    = lc_pdf_format
                                                   i_attachment_subject = lv_subject
                                                   i_att_content_hex    = lt_pdf_content[] ).

          CATCH cx_document_bcs INTO lo_bcs_exception.
        ENDTRY.

        lo_sender = cl_cam_address_bcs=>create_internet_address( i_address_string = lv_remitente
                                                                 i_address_name   = lc_fvg_emisor_name ).

        lo_send_request->set_sender( lo_sender ).
        lo_send_request->set_document( lo_document ).

        LOOP AT lt_adr6[] ASSIGNING <lfs_adr6>.
          lo_recipient = cl_cam_address_bcs=>create_internet_address( <lfs_adr6>-smtp_addr ).
          lo_send_request->add_recipient( lo_recipient ).
        ENDLOOP.

        lv_sent_to_all = lo_send_request->send( i_with_error_screen = abap_true ).

        CALL FUNCTION 'TH_IN_UPDATE_TASK'
          IMPORTING
            in_update_task = lv_update_task.

        IF lv_update_task EQ 0.
          COMMIT WORK AND WAIT.
          WAIT UP TO 2 SECONDS.
        ENDIF.

        MESSAGE s888(sabapdocu) WITH 'Se han generado los envios en la transacción SOST'.
        gv_enviado = ''.
      CATCH cx_bcs INTO lo_bcs_exception.
        MESSAGE i865(so) WITH lo_bcs_exception->error_type.

        CLEAR lv_update_task.

        gv_enviado = 'X'.

    ENDTRY.

  ENDIF.



ENDFORM.

*[ END OF MODIF]---------------------------------------F12510-19.04.2018-OT:DEVK908962

*&---------------------------------------------------------------------*
*&      Form  SET_BODY
*&---------------------------------------------------------------------*

FORM set_body  CHANGING et_body_text TYPE bcsy_text.

  REFRESH et_body_text[].

  APPEND: 'Estimado Cliente:' TO et_body_text[],
          INITIAL LINE TO et_body_text[],
          'Se adjunta recibo confeccionado.' TO et_body_text[],
          INITIAL LINE TO et_body_text[],
          'Por favor, ante cualquier consulta, dirigirse a la siguiente dirección de mail cobranzas_empresas@fravega.com.ar' TO et_body_text[],
          INITIAL LINE TO et_body_text[],
          'Dpto. Cobranzas Corporativas' TO et_body_text[],
          INITIAL LINE TO et_body_text[],
          'FRAVEGA S.A.C.I e I.' TO et_body_text[].

ENDFORM.