**********************Documentación Principal **************************
* Nombre del programa : ZRFI_REPORTE_DEUDORES_SEL
* Fecha               : 08/03/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que detalla datos de Clientes deudores.
* Versión             : 1.0
************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZRFI_REPORTE_DEUDORES_SEL
*&---------------------------------------------------------------------*




*----------------------------------------------------------------------*
* PARAMETROS DE SELECCION                                              *
*----------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-000.
  PARAMETERS:     p_soc   TYPE bukrs OBLIGATORY.
  SELECT-OPTIONS: s_cli   FOR kna1-kunnr OBLIGATORY,
                  s_grcta FOR kna1-ktokd,
                  s_dto   FOR knvk-abtnr OBLIGATORY.
 SELECTION-SCREEN END OF BLOCK b1.

 SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-001.
   PARAMETERS: p_orgvt  TYPE vkorg OBLIGATORY,
               p_cnldst TYPE vtweg OBLIGATORY,
               p_sect   TYPE spart OBLIGATORY.
 SELECTION-SCREEN END OF BLOCK b2.