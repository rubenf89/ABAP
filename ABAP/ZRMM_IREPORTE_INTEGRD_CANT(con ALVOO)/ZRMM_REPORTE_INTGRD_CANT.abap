**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTGRD_CANT.
* Fecha               : 19/06/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla las cantidades de documentos materiales faltantes
* Versión             : 1.0
************************************************************************

REPORT zrmm_reporte_intgrd_cant.

INCLUDE: zrmm_reporte_intgrd_cant_top,
         zrmm_reporte_intgrd_cant_sel,
         zrmm_reporte_intgrd_cant_form,
         zrmm_reporte_intgrd_cant_o01,
         zrmm_reporte_intgrd_cant_i01.

*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM armo_tabla_alv.
  IF gt_mat[] IS INITIAL.
    MESSAGE text-001 TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM display_data.
  ENDIF.