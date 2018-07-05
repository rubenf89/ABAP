**********************Documentación Principal **************************
* Nombre del programa : ZRFI_REPORTE_DEUDORES
* Fecha               : 08/03/2018
* Autor               : Ruben Figueredo (F12510)
* Fecha de ultima mod :
* Descripción         : Reporte que detalla datos de Clientes deudores.
* Versión             : 1.0
************************************************************************


REPORT zrfi_reporte_deudores.

INCLUDE: zrfi_reporte_deudores_top,
         zrfi_reporte_deudores_sel,
         zrfi_reporte_deudores_form,
         zrfi_reporte_deudores_o01,
         zrfi_reporte_deudores_i01.

*----------------------------------------------------------------------*
* START-OF-SELECTION                                                   *
*----------------------------------------------------------------------*

START-OF-SELECTION.
  PERFORM obtener_clientes.
  PERFORM armo_tabla_alv.
  IF gt_cli[] IS INITIAL.
    MESSAGE text-004 TYPE 'S' DISPLAY LIKE 'E'.
  ELSE.
    PERFORM display_data.
  ENDIF.