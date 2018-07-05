**********************Documentación Principal **************************
* Nombre del programa : ZRMM_REPORTE_INTEGRIDAD_STOCK.
* Fecha               : 05/05/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que Detalla la integridad de los materiales
* Versión             : 1.0
************************************************************************

REPORT zrmm_reporte_integridad.

INCLUDE: zrmm_reporte_integridad_top,
         zrmm_reporte_integridad_sel,
         zrmm_reporte_integridad_form,
         zrmm_reporte_integridad_o01,
         zrmm_reporte_integridad_i01.


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