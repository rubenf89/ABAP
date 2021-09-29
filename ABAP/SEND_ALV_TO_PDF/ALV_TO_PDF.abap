*&---------------------------------------------------------------------*
*&  Include           ZRMM_CONSULTAR_STOCK_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_start_of_selection .

  DATA:
        lv_out_parameters LIKE  pri_params,
        lc_valid(1)       TYPE c,
        lv_variante       TYPE char20,
        lv_pdf_size       TYPE so_obj_len,
        ls_pdf_content    TYPE solix_tab.


  PERFORM:  f_get_print_parameters USING lc_valid
                                  CHANGING lv_out_parameters,

            f_submit_rm07mlbs USING lv_variante
                                    lv_out_parameters,

            f_convert_job_to_pdf CHANGING lv_pdf_size
                                          ls_pdf_content,


            f_send_mail USING lv_pdf_size
                               ls_pdf_content.


ENDFORM.                    "
*&---------------------------------------------------------------------*
*&      Form  F_SEND_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_send_mail USING lv_pdf_size
                       lt_pdf_content   .

  DATA: lv_name1           TYPE t001w-name1,
        lv_fecha           TYPE string,
        lv_sent_to_all     TYPE os_boolean,
        lv_email           TYPE ad_smtpadr,
        lv_subject         TYPE so_obj_des,
        lv_file_name       TYPE sood-objdes,
        lt_addr            TYPE bcsy_smtpa,

        ls_binary_content  TYPE solix_tab,
        ls_main_text       TYPE bcsy_text,
        ls_correos         TYPE zmm_mails_vend,

        lt_dlientries      TYPE TABLE OF sodlienti1,
        lt_correos         TYPE TABLE OF zmm_mails_vend,
        lt_email           TYPE TABLE OF ad_smtpadr " Email ID
        .

  DATA: lo_send_request       TYPE REF TO cl_bcs,
        lo_document           TYPE REF TO cl_document_bcs,
        lo_sender             TYPE REF TO cl_sapuser_bcs,
        lo_recipient          TYPE REF TO if_recipient_bcs,
        lo_exception_info     TYPE REF TO if_os_exception_info,
        lo_bcs_exception      TYPE REF TO cx_bcs.

*  CONSTANTS: lc_subject TYPE string VALUE 'Stock ',
*             lc_stock   TYPE string VALUE 'stock_'.

  SELECT SINGLE name1
    FROM t001w
    INTO lv_name1
    WHERE werks = p_werks.

  CONCATENATE sy-datum+6(2)
              '.'
              sy-datum+4(2)
              '.'
              sy-datum(4)
              '-'
              sy-uzeit(2)
              ':'
              sy-uzeit+2(2)
        INTO lv_fecha.

****ASUNTO DEL CORREO*****
  CONCATENATE text-002 "lc_subject
              lv_name1
              lv_fecha(5)
              '-'
              lv_fecha+11(5)
        INTO lv_subject
        SEPARATED BY space.

****NOMBRE DEL ARCHIVO****
  CONCATENATE text-003 "lc_stock
              '_'
              lv_name1
              '_'
              sy-datum+6(2)
              sy-datum+4(2)
              sy-datum(4)
              sy-uzeit
        INTO lv_file_name
        .

  TRY.
*-------- create persistent send request ------------------------

      lo_send_request = cl_bcs=>create_persistent( ).

*-------- create and set document with attachment ---------------
*create document object from internal table with text

      lo_document = cl_document_bcs=>create_document( i_type    = 'RAW'
*                                                     i_text    =
                                                      i_subject = lv_subject ).


*add the spread sheet as attachment to document object
      lo_document->add_attachment( i_attachment_type    = 'PDF' "#EC NOTEXT
                                   i_attachment_subject = lv_file_name "#EC NOTEXT
                                   i_attachment_size    = lv_pdf_size                    "Size
                                   i_att_content_hex    = lt_pdf_content ).


*add document object to send request
      lo_send_request->set_document( lo_document ).
**
      lo_sender = cl_sapuser_bcs=>create( sy-uname ).

      lo_send_request->set_sender( i_sender = lo_sender ).

*--------- add recipient (e-mail address)-----------------------

      SELECT *
        FROM  zmm_mails_vend
        INTO TABLE lt_correos
        WHERE org_venta = p_vkorg
          AND centro    = p_werks
        .

      IF sy-subrc = 4.
        MESSAGE e000(zmm) WITH text-000.
        EXIT.
      ENDIF.
      .

      LOOP AT lt_correos INTO ls_correos.
        lv_email = ls_correos-mail.
        lo_recipient = cl_cam_address_bcs=>create_internet_address( lv_email ).
        lo_send_request->add_recipient( lo_recipient ).
      ENDLOOP.

*---------Send Mail------------*
      lo_send_request->send_request->set_link_to_outbox( abap_true ).

      lv_sent_to_all = lo_send_request->send( i_with_error_screen = 'X' ).

      COMMIT WORK.

    CATCH cx_bcs INTO lo_bcs_exception.
      MESSAGE i865(so) WITH lo_bcs_exception->error_type.

      IF sy-subrc EQ 0.

        MESSAGE s000(zmm) WITH text-001.

      ENDIF.

  ENDTRY.

ENDFORM.                    " F_SEND_MAIL
*&---------------------------------------------------------------------*
*&      Form  F_GET_PRINT_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LC_VALID  text
*      <--P_LV_OUT_PARAMETERS  text
*----------------------------------------------------------------------*
FORM f_get_print_parameters  USING    p_lc_valid
                             CHANGING p_lv_out_parameters LIKE  pri_params.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      authority              = space
      copies                 = '1'
      cover_page             = space
      data_set               = space
      department             = space
      destination            = space
      expiration             = '1'
      immediately            = space
      layout                 = space
      mode                   = space
      new_list_id            = abap_true
      no_dialog              = abap_true
      user                   = sy-uname
    IMPORTING
      out_parameters         = p_lv_out_parameters
      valid                  = p_lc_valid
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " F_GET_PRINT_PARAMETERS
*&---------------------------------------------------------------------*
*&      Form  F_SUBMIT_RM07MLBS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_VARIANTE  text
*      -->P_LV_OUT_PARAMETERS  text
*----------------------------------------------------------------------*
FORM f_submit_rm07mlbs  USING    p_lv_variante
                                 p_lv_out_parameters LIKE  pri_params.

  DATA:   p_linsz  LIKE sy-linsz VALUE 132,         " Line size
          p_paart  LIKE sy-paart VALUE 'X_65_132',  " Paper Format
          wa_varid TYPE varid.

  DATA: i_valtab  TYPE STANDARD TABLE OF rsparams.

  FIELD-SYMBOLS <fs_s_valtab> TYPE rsparams.

  p_lv_out_parameters-linsz = p_linsz.
  p_lv_out_parameters-paart = p_paart.

  p_lv_variante = p_varian.

  " Chequeo si existe la variante
  SELECT SINGLE * FROM varid
         INTO wa_varid
         WHERE report = 'RM07MLBS'
         AND variant = p_varian.

  IF sy-subrc NE 0.
    "Mensaje de error
  ENDIF.

  " Obtengo datos de variante
  CALL FUNCTION 'RS_VARIANT_CONTENTS'
    EXPORTING
      report                = 'RM07MLBS'
      variant               = p_varian
    TABLES
*     L_PARAMS              =
*     L_PARAMS_NONV         =
*     L_SELOP               =
*     L_SELOP_NONV          =
      valutab               = i_valtab
*     VALUTABL              =
*     OBJECTS               =
*     FREE_SELECTIONS_DESC  =
*     FREE_SELECTIONS_VALUE =
    EXCEPTIONS
      variant_non_existent  = 1
      variant_obsolete      = 2
      OTHERS                = 3.

  IF sy-subrc NE 0.
    "Mensaje de error
  ENDIF.

  " Reemplazo el parametro centro
  LOOP AT i_valtab ASSIGNING <fs_s_valtab>.

    IF <fs_s_valtab>-selname = 'WERKS'.
      <fs_s_valtab>-low = p_werks.
      <fs_s_valtab>-sign = 'I'.
      <fs_s_valtab>-option = 'EQ'.
    ENDIF.

  ENDLOOP.

*  CONDENSE p_lv_variante NO-GAPS.

  SUBMIT rm07mlbs
        TO SAP-SPOOL WITHOUT SPOOL DYNPRO
                             SPOOL PARAMETERS p_lv_out_parameters
*                          USING SELECTION-SET p_lv_variante
                         WITH SELECTION-TABLE i_valtab
                         "EXPORTING LIST TO MEMORY
                         "VIA SELECTION-SCREEN
                                   AND RETURN.


ENDFORM.                    " F_SUBMIT_RM07MLBS
*&---------------------------------------------------------------------*
*&      Form  F_CONVERT_JOB_TO_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_PDF_SIZE  text
*      <--P_LS_PDF_CONTENT  text
*----------------------------------------------------------------------*
FORM f_convert_job_to_pdf  CHANGING p_lv_pdf_size
                                    p_ls_pdf_content.

  TABLES: tsp01. "spools

  DATA: client            LIKE tst01-dclient,
        name              LIKE tst01-dname,
        objtype           LIKE rststype-type,
        type              LIKE rststype-type,
        mi_rqident        LIKE tsp01-rqident,
        lv_rq2name        LIKE tsp01-rq2name,
        lv_out_parameters LIKE  pri_params.

  DATA:
        lc_valid(1)      TYPE c.

  DATA:
        lv_variante          TYPE char20,
        lv_pdf_size          TYPE so_obj_len,
        lv_spool             TYPE tsp01-rqident,

        ls_pdf_content       TYPE solix_tab,
        ls_pdf_xstring       TYPE xstring,

        lt_pdf               TYPE TABLE OF tline,
        it_pdf_table         TYPE  rcl_bag_tline,
        ls_pdfline           LIKE LINE OF it_pdf_table,
        ls_pdf               LIKE LINE OF lt_pdf.

  FIELD-SYMBOLS:
                 <l_xline>   TYPE x.

  CONCATENATE sy-repid+0(9)
  sy-uname+0(3)
  INTO lv_rq2name .

  SELECT * FROM tsp01 WHERE  rq2name = lv_rq2name
      ORDER BY rqcretime DESCENDING.
    EXIT.
  ENDSELECT.

  gd_spool_nr =  tsp01-rqident.

  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = gd_spool_nr
      no_dialog                = abap_false
    IMPORTING
      pdf_bytecount            = gd_bytecount
    TABLES
      pdf                      = lt_pdf
    EXCEPTIONS
      err_no_abap_spooljob     = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_destdevice       = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ELSE.

    LOOP AT lt_pdf INTO ls_pdf.
      ASSIGN ls_pdf TO <l_xline> CASTING.
      CONCATENATE ls_pdf_xstring <l_xline> INTO ls_pdf_xstring IN BYTE MODE.
    ENDLOOP.

*   get PDF xstring and convert it to BCS format
    p_lv_pdf_size = xstrlen( ls_pdf_xstring ).
    p_ls_pdf_content = cl_document_bcs=>xstring_to_solix( ip_xstring = ls_pdf_xstring ).

  ENDIF.

ENDFORM.                    " F_CONVERT_JOB_TO_PDF