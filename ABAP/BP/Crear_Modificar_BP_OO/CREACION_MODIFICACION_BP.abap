FORM f_crea_prov_api USING pe_def_nuevoprov TYPE zha001_defaults
                           pe_nuevoprovcli TYPE type_nuevoprovcli
                     CHANGING ps_ret TYPE bapiretc
                              ps_lifn TYPE lfa1-lifnr.

     DATA: lt_data   TYPE cvis_ei_extern_t,
           ls_data   LIKE LINE OF lt_data,
           ls_return TYPE bapiretm.

    DATA: lv_bool TYPE abap_bool,
          lv_kunnr TYPE kunnr.

          PERFORM F_valida_cliente CHANGING pe_nuevoprovcli
                                            lv_bool
                                            lv_kunnr      .

      IF lv_bool EQ abap_false.
        PERFORM f_create_bp USING pe_def_nuevoprov
                                  pe_nuevoprovcli
                            CHANGING lt_data .
      ELSE.
        PERFORM f_update_bp USING pe_def_nuevoprov
                                  pe_nuevoprovcli   "Datos existentes en el BP
                                  lv_kunnr
                         CHANGING lt_data    .
      ENDIF.


  cl_md_bp_maintain=>maintain(
    EXPORTING
      i_data     = lt_data
*    i_test_run =
    IMPORTING
      e_return   = ls_return ).

  READ TABLE ls_return INTO DATA(ls_ret) INDEX 1.
  CHECK sy-subrc EQ 0.
  READ TABLE ls_ret-object_msg INTO ps_ret WITH KEY type = 'E'.
  IF sy-subrc NE 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    SELECT SINGLE lifnr FROM lfa1 AS lfa1
    INNER JOIN cvi_vend_link AS cvi_vend_link
    ON  lfa1~lifnr = cvi_vend_link~vendor
    INTO ps_lifn
    WHERE cvi_vend_link~partner_guid = ls_ret-object_key.

    MESSAGE s156(zhacienda) WITH ps_lifn INTO DATA(lv_dummy).
    ps_ret-id = sy-msgid.
    ps_ret-type = sy-msgty.
    ps_ret-number = sy-msgno.
    ps_ret-message_v1 = sy-msgv1.
    ps_ret-message_v2 = sy-msgv2.
    ps_ret-message_v3 = sy-msgv3.
    ps_ret-message_v4 = sy-msgv4.

  ELSE.
    sy-subrc = 1.
  ENDIF.

ENDFORM.


FORM f_update_bp  USING  pe_def_nuevoprov TYPE zha001_defaults
                         pe_nuevoprovcli  TYPE type_nuevoprovcli
                         pe_kunnr         TYPE kunnr
                CHANGING lt_data          TYPE cvis_ei_extern_t.

  DATA:
    ls_data     LIKE LINE OF lt_data,
    ls_pur      LIKE LINE OF ls_data-vendor-purchasing_data-purchasing,
    ls_roles    LIKE LINE OF ls_data-partner-central_data-role-roles,
    ls_company  LIKE LINE OF ls_data-vendor-company_data-company..

    "Obtiene el UID del parrner y la direccion
    SELECT SINGLE a~partner_guid, b~partner
        FROM cvi_cust_link AS a
        INNER JOIN but000  AS b ON a~partner_guid = b~partner_guid
        LEFT OUTER JOIN but020  AS c ON c~partner = b~partner
        WHERE customer = @pe_kunnr
    INTO @DATA(ls_partner).

  "-- Partner / Header
  ls_data-partner-header-object_instance-bpartnerguid                = ls_partner-partner_guid.
  ls_data-partner-header-object_instance-bpartner                    = ls_partner-partner.
  ls_data-partner-header-object_task                                 = 'U'.

  "DATOS ROLES
  ls_roles-task                             = 'I'.
  ls_roles-data_key                         = 'FLVN00'.
  ls_roles-data-rolecategory                = 'FLVN00'.
  ls_roles-data-valid_from                  = sy-datum.
  ls_roles-data-valid_to                    = '99991231'.
  ls_roles-currently_valid                  = abap_true.

  ls_roles-datax-valid_from                 = abap_true.
  ls_roles-datax-valid_to                   = abap_true.

  APPEND ls_roles TO ls_data-partner-central_data-role-roles.

  CLEAR ls_roles.
  ls_roles-task                             = 'I'.
  ls_roles-data_key                         = 'FLVN01'.
  ls_roles-data-rolecategory                = 'FLVN01'.
  ls_roles-data-valid_from                  = sy-datum.
  ls_roles-data-valid_to                    = '99991231'.
  ls_roles-currently_valid                  = abap_true.

  ls_roles-datax-valid_from                 = abap_true.
  ls_roles-datax-valid_to                   = abap_true.

  APPEND ls_roles TO ls_data-partner-central_data-role-roles.

  ls_data-partner-central_data-role-time_dependent = abap_true.

   "-- Partner / Vendor

  ls_data-vendor-header-object_task              = 'I'.
  ls_data-vendor-central_data-central-data-ktokk = pe_def_nuevoprov-ktokk.
  ls_data-vendor-central_data-central-data-fityp = pe_nuevoprovcli-fityp.
  ls_data-vendor-central_data-central-data-sperr = abap_true.

  ls_data-vendor-central_data-central-datax-ktokk = abap_true.
  ls_data-vendor-central_data-central-datax-fityp = abap_true.
  ls_data-vendor-central_data-central-datax-sperr = abap_true.


   "-- Partner / Vendor / Company
  ls_company-task                                = 'I'.
  ls_company-data_key-bukrs                      = 'RIOP'.
  ls_company-data-akont                          = pe_def_nuevoprov-akont_prov.       "Cuenta asociada en la contabilidad principal
  ls_company-data-fdgrv                          = pe_def_nuevoprov-fdgrv.            "Grupo de tesorería
  ls_company-data-zterm                          = pe_def_nuevoprov-zterm.
  ls_company-data-altkn                          = ls_partner-partner.

  ls_company-datax-akont                         = abap_true.
  ls_company-datax-fdgrv                         = abap_true.
  ls_company-datax-zterm                         = abap_true.
  ls_company-datax-altkn                         = abap_true.

  APPEND ls_company TO ls_data-vendor-company_data-company.

  ls_data-vendor-company_data-current_state = abap_true.

  "-- Partner / Vendor / Purchasing

  ls_pur-task           = 'I'.
  ls_pur-data_key-ekorg = pe_def_nuevoprov-ekorg.                       "Organización de compras
  ls_pur-data-zterm     = pe_def_nuevoprov-zterm.
  ls_pur-data-kalsk     = pe_def_nuevoprov-kalsk.
  ls_pur-data-ekgrp     = pe_def_nuevoprov-ekgrp.
  ls_pur-data-waers     = pe_def_nuevoprov-curr.

  ls_pur-datax-zterm    = abap_true.
  ls_pur-datax-kalsk    = abap_true.
  ls_pur-datax-ekgrp    = abap_true.
  ls_pur-datax-waers    = abap_true.

  ls_data-vendor-purchasing_data-current_state = abap_true.

  APPEND ls_pur TO ls_data-vendor-purchasing_data-purchasing.

  APPEND ls_data TO lt_data.

ENDFORM.

FORM f_create_bp  USING pe_def_nuevoprov TYPE zha001_defaults
                           pe_nuevoprovcli TYPE type_nuevoprovcli
                   CHANGING lt_data   TYPE cvis_ei_extern_t        .

  DATA:
    ls_data   LIKE LINE OF lt_data,
    ls_return TYPE bapiretm.

  ls_data-partner-header-object_task = 'I'.

  ls_data-partner-header-object_instance-bpartnerguid = cl_system_uuid=>if_system_uuid_static~create_uuid_c32( ).

  ls_data-partner-central_data-common-data-bp_control-category = '2'.
  ls_data-partner-central_data-common-data-bp_control-grouping = pe_def_nuevoprov-ktokk.

  ls_data-partner-central_data-common-data-bp_centraldata-searchterm1 = pe_nuevoprovcli-stcd1.
  ls_data-partner-central_data-common-data-bp_centraldata-partnerlanguage = 'S'.
  ls_data-partner-central_data-common-data-bp_centraldata-partnertype = ''.
  ls_data-partner-central_data-common-data-bp_centraldata-title_key = '0003'.

  ls_data-partner-central_data-common-data-bp_organization-name1 = pe_nuevoprovcli-name1.

  ls_data-partner-central_data-role-current_state = 'X'.

  DATA ls_roles LIKE LINE OF ls_data-partner-central_data-role-roles.

  ls_roles-task = 'I'.
  ls_roles-data_key = 'FLVN00'.
  ls_roles-data-rolecategory = 'FLVN00'.
  ls_roles-data-valid_from   = sy-datum.
  ls_roles-data-valid_to     = '99991231'.
  APPEND ls_roles TO ls_data-partner-central_data-role-roles.
  ls_roles-task = 'I'.
  ls_roles-data_key = 'FLVN01'.
  ls_roles-data-rolecategory = 'FLVN01'.
  ls_roles-data-valid_from   = sy-datum.
  ls_roles-data-valid_to     = '99991231'.
  APPEND ls_roles TO ls_data-partner-central_data-role-roles.

  DATA ls_taxn LIKE LINE OF ls_data-partner-central_data-taxnumber-taxnumbers.
  ls_data-partner-central_data-taxnumber-current_state = ''.
  IF NOT pe_nuevoprovcli-stcd1 IS INITIAL.
    ls_taxn-task = 'I'.
    ls_taxn-data_key-taxtype = 'AR1A'.
    ls_taxn-data_key-taxnumber = pe_nuevoprovcli-stcd1.  " CUIT
    APPEND ls_taxn TO ls_data-partner-central_data-taxnumber-taxnumbers.
  ENDIF.
  IF NOT pe_nuevoprovcli-stcd3 IS INITIAL.
    ls_taxn-task = 'I'.
    ls_taxn-data_key-taxtype = 'AR3'.
    ls_taxn-data_key-taxnumber = pe_nuevoprovcli-stcd3.        "Inscrpción ONCCA
    APPEND ls_taxn TO ls_data-partner-central_data-taxnumber-taxnumbers.
  ENDIF.

  DATA ls_ad LIKE LINE OF ls_data-partner-central_data-address-addresses.
  ls_ad-task = 'I'.
  ls_ad-data-postal-data-street = pe_nuevoprovcli-stras.       "calle
  ls_ad-data-postal-data-house_no = pe_nuevoprovcli-house_num1.  "numero
  ls_ad-data-postal-data-region = pe_nuevoprovcli-regio.       "Región (Estado federal, "land", provincia, condado)
  ls_ad-data-postal-data-city = pe_nuevoprovcli-ort01.       "poblacion
  ls_ad-data-postal-data-postl_cod1 = pe_nuevoprovcli-pstlz.       "cod postal
  ls_ad-data-postal-data-country = pe_nuevoprovcli-land1.       "Clave de país
  ls_ad-data-postal-data-langu = 'S'. " le_def_nuevoprov-langu,  "idioma

  IF NOT pe_nuevoprovcli-telf1 IS INITIAL.
    DATA ls_tel LIKE LINE OF ls_ad-data-communication-phone-phone.
    ls_tel-contact-task = 'I'.
    ls_tel-contact-data-telephone = pe_nuevoprovcli-telf1.
    ls_tel-contact-data-country = 'AR'.
    ls_tel-contact-data-r_3_user = '1'.
    ls_tel-contact-data-std_no = 'X'.
    ls_tel-contact-data-valid_from = sy-datum.
    ls_tel-contact-data-valid_to = '99991231000000'.
    APPEND ls_tel TO ls_ad-data-communication-phone-phone.

  ENDIF.

  DATA ls_ad_usage LIKE LINE OF ls_ad-data-addr_usage-addr_usages.
  ls_ad_usage-task = 'I'.
  ls_ad_usage-data_key-addresstype = 'XXDEFAULT'.
  ls_ad_usage-data_key-valid_to = 99991231.
  APPEND ls_ad_usage TO ls_ad-data-addr_usage-addr_usages.

  APPEND ls_ad TO ls_data-partner-central_data-address-addresses.

  ls_data-vendor-header-object_task = 'I'.
  ls_data-vendor-central_data-central-data-ktokk = pe_def_nuevoprov-ktokk.             "Grupo de cuentas acreedor
  ls_data-vendor-central_data-central-data-fityp = pe_nuevoprovcli-fityp.        "Clase impuesto
  ls_data-vendor-central_data-central-data-sperr = 'X'.

  DATA ls_company LIKE LINE OF ls_data-vendor-company_data-company.
  ls_company-task = 'I'.
  ls_company-data_key-bukrs = 'RIOP'.
  ls_company-data-akont = pe_def_nuevoprov-akont_prov.       "Cuenta asociada en la contabilidad principal
  ls_company-data-fdgrv = pe_def_nuevoprov-fdgrv.            "Grupo de tesorería
  ls_company-data-zterm = pe_def_nuevoprov-zterm.
  APPEND ls_company TO ls_data-vendor-company_data-company.

  DATA ls_pur LIKE LINE OF ls_data-vendor-purchasing_data-purchasing.
  ls_pur-task = 'I'.
  ls_pur-data_key-ekorg = pe_def_nuevoprov-ekorg.             "Organización de compras
  ls_pur-data-zterm     = pe_def_nuevoprov-zterm.
  ls_pur-data-kalsk     = pe_def_nuevoprov-kalsk.
  ls_pur-data-ekgrp     = pe_def_nuevoprov-ekgrp.
  ls_pur-data-waers     = pe_def_nuevoprov-curr.
  APPEND ls_pur TO ls_data-vendor-purchasing_data-purchasing.

  APPEND ls_data TO lt_data.

ENDFORM.

FORM f_valida_cliente   " USING pe_nuevoprovcli TYPE type_nuevoprovcli
                      CHANGING pe_nuevoprovcli TYPE type_nuevoprovcli
                               pc_bool         TYPE abap_bool
                               pc_kunnr        TYPE kunnr
                                 .

     SELECT SINGLE *
        FROM kna1
        WHERE stcd1 = @pe_nuevoprovcli-stcd1
        INTO @DATA(ls_kna1).

     IF sy-subrc = 0.
      pc_bool = abap_true.
      MOVE-CORRESPONDING ls_kna1 TO pe_nuevoprovcli.
      pc_kunnr = ls_kna1-kunnr.
      ELSE.
      pc_bool = abap_false.
      ENDIF.

ENDFORM.


