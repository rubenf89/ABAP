**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTGRD_CANT.
* Fecha               : 19/06/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla las cantidades de documentos materiales faltantes
* Versión             : 1.0
************************************************************************
*&---------------------------------------------------------------------*
*&  Include           ZRMM_REPORTE_INTGRD_CANT_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_mblnr FOR mkpf-mblnr,
                s_bktxt FOR mkpf-bktxt,
                s_bldat FOR mkpf-bldat,
                s_budat FOR mkpf-budat OBLIGATORY,
                s_bwart FOR mseg-bwart OBLIGATORY.

SELECTION-SCREEN: END OF BLOCK b1.