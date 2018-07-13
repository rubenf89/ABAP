*-----------------------------------------------------------------------
*        Modulpool 'Parametrisierung des Zahlungsprogramms'
*-----------------------------------------------------------------------

*REPORT ZRFI_PAGO_INTERBANKING.
.


*eject
*-----------------------------------------------------------------------
*        Report-Header / Tabellen / Daten / Field-Symbols
*-----------------------------------------------------------------------
INCLUDE f110vtop.
*INCLUDE: zrfi_pago_interbanking_top.
INCLUDE: zrfi_pago_interbanking_top.
INCLUDE: zrfi_pago_interbanking_pai,
         zrfi_pago_interbanking_form.
*------- Selektionsoptionen --------------------------------------------
INCLUDE f110vsel.

*------- List-Bearbeitung ----------------------------------------------
INCLUDE f110vlst.

*eject
*-----------------------------------------------------------------------
*        PBO - Module
*-----------------------------------------------------------------------
INCLUDE f110vo00.

*eject
*-----------------------------------------------------------------------
*        PAI - Module
*-----------------------------------------------------------------------
INCLUDE f110vi00.

*eject
*-----------------------------------------------------------------------
*        FORM-Routinen ( alphabetisch )
*-----------------------------------------------------------------------
*        INCLUDE F110VFA0.
INCLUDE f110vfb0.
*        INCLUDE F110VFC0.
INCLUDE f110vfd0.
*        INCLUDE F110VFE0.
INCLUDE f110vff0.
*        INCLUDE F110VFG0.
*        INCLUDE F110VFH0.
*        INCLUDE F110VFI0.
INCLUDE f110vfj0.
*        INCLUDE F110VFK0.
INCLUDE f110vfl0.
*        INCLUDE F110VFM0.
*        INCLUDE F110VFN0.
INCLUDE f110vfo0.
INCLUDE f110vfp0.
*        INCLUDE F110VFQ0.
INCLUDE f110vfr0.
INCLUDE f110vfs0.
INCLUDE f110vft0.
*        INCLUDE F110VFU0.
INCLUDE f110vfv0.
INCLUDE f110vfw0.
*        INCLUDE F110VFX0.
*        INCLUDE F110VFY0.
*        INCLUDE F110VFZ0.

*eject
*-----------------------------------------------------------------------
*        Module und FORM-Routinen für F4-HELP
*-----------------------------------------------------------------------
INCLUDE f110vhlp.