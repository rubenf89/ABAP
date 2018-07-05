**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTEGRIDAD_STOCK.
* Fecha               : 05/05/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla la integridad de los materiales
* Versión             : 1.0
************************************************************************

*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTEGRIDAD_SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*
* Parámetros de entrada
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_mblnr FOR mkpf-mblnr,
                s_bktxt FOR mkpf-bktxt,
                s_bldat FOR mkpf-bldat,
                s_budat FOR mkpf-budat OBLIGATORY,
                s_bwart FOR mseg-bwart OBLIGATORY.



SELECTION-SCREEN: END OF BLOCK b1.