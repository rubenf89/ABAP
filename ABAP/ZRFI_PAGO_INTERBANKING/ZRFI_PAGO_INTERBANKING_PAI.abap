*----------------------------------------------------------------------*
***INCLUDE ZRFI_PAGO_INTERBANKING_PAI.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ZINPUT_0200_B  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

MODULE zinput_0200_b INPUT.
  IF ok-code = 'PBT'.
    PERFORM get_data_reguh.
    PERFORM armar_registro.
    IF NOT gt_final[] IS INITIAL.
      PERFORM descargar_fichero.
    ENDIF.
  ENDIF.
ENDMODULE.