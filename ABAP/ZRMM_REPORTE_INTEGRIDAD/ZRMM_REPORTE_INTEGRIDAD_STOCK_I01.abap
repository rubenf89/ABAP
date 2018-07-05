**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTEGRIDAD_STOCK.
* Fecha               : 05/05/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla la integridad de los materiales
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTEGRIDAD_I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

    CASE sy-ucomm.
    WHEN 'BACK' OR 'EXIT' OR 'CANCEL'.
      SET SCREEN 0.
  ENDCASE.

ENDMODULE.