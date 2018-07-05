**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTGRD_CANT.
* Fecha               : 19/06/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla las cantidades de documentos materiales faltantes
* Versión             : 1.0
************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTGRD_CANT_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*

MODULE user_command_0100 INPUT.
  DATA wl_command TYPE sy-ucomm.

  wl_command = gv_ok_code.
  CLEAR gv_ok_code.

  CASE wl_command.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SET_ALV  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE set_alv OUTPUT.


  IF ( gro_custom_container IS NOT BOUND ).

*   Si es la primera vez, instancia las clases y muestra los datos de la tabla

    CREATE OBJECT gro_custom_container
      EXPORTING
        container_name              = 'ZCONTENEDOR_ALV'
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5
        OTHERS                      = 6.

    IF ( sy-subrc <> 0 ).
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    TRY .
        cl_salv_table=>factory(
                 EXPORTING
                     r_container    = gro_custom_container
                     list_display   = ' '
                   IMPORTING
                     r_salv_table   = gro_table
                   CHANGING
                     t_table        = gt_mat ).

        DATA(gro_functions) = gro_table->get_functions( ).
        gro_functions->set_all( abap_true ).

        gro_display = gro_table->get_display_settings( ).
        gro_display->set_striped_pattern( cl_salv_display_settings=>true ).


      CATCH cx_salv_msg INTO gro_cx_salv.
*Gestionamos las excepciones que puedan suceder
        gro_mensaje = gro_cx_salv->get_text( ).
        MESSAGE gro_mensaje TYPE 'E'.
    ENDTRY.

    TRY .
        gro_columnas ?= gro_table->get_columns( ).
        gro_columnas->set_optimize( 'X' ). "Optimizar automa. ancho de TODAS las columnas

*Oculatar columnas no deseadas
        gro_columna ?= gro_columnas->get_column( 'MJAHR' ).
        gro_columna->set_visible( abap_false ).


        gro_columna ?= gro_columnas->get_column( columnname = 'XBLNR').
        gro_columna->set_visible( value = if_salv_c_bool_sap=>false ).

*Cambiar la descpcion de las columnas
        gro_columna ?= gro_columnas->get_column( columnname = 'BKTXT' ).
        gro_columna->set_short_text( VALUE = 'Nro.Int' ).
        gro_columna->set_long_text( value = 'Nro.Integridad' ).

        gro_columna ?= gro_columnas->get_column( columnname = 'RNGINI' ).
        gro_columna->set_long_text( value = 'Rango inicial' ).

        gro_columna ?= gro_columnas->get_column( columnname = 'RNGFIN' ).
        gro_columna->set_long_text( value = 'Rango final' ).

        gro_columna ?= gro_columnas->get_column( columnname = 'FALTAN' ).
        gro_columna->set_long_text( value = 'Faltan' ).


      CATCH cx_salv_msg INTO gro_cx_salv.
        gro_mensaje = gro_cx_salv->get_text( ).
        MESSAGE gro_mensaje TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
    gro_table->display( ).
  ELSE.
*   Si ya estan instanciadas las clases, refrescamos los datos de la pantalla
    gro_table->refresh( ).
  ENDIF.

ENDMODULE.