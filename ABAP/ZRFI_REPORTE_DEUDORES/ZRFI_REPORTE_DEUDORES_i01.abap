* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que detalla datos de clientes deudores.
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRFI_REPORTE_DEUDORES_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
    CASE sy-ucomm.
    WHEN 'BACK'OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
  ENDCASE.
ENDMODULE.