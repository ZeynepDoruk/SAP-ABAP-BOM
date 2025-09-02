*&---------------------------------------------------------------------*
*& Report Z_MAL_ALV
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_mal_alv.


*
*data : gt_zzp_malzeme type STANDARD TABLE OF zzp_malzeme,
*      gs_malzeme type zzp_malzeme,
*      go_salv  TYPE REF TO cl_salv_table.
*
*
*
*START-OF-SELECTION.
*
*select * from zzp_malzeme into table gt_zzp_malzeme .
*
* cl_salv_table=>factory(
*
*   IMPORTING
*     r_salv_table   =      go_salv                      " Basis Class Simple ALV Tables
*   CHANGING
*     t_table        = gt_zzp_malzeme
* ).
** CATCH cx_salv_msg. " ALV: General Error Class with Message( )
*go_salv->display( ).

TABLES: zzp_malzeme.

DATA: gt_zzp_malzeme TYPE STANDARD TABLE OF zzp_malzeme,
      gs_zzp_malzeme TYPE zzp_malzeme.

DATA: go_container TYPE REF TO cl_gui_custom_container,
      go_grid      TYPE REF TO cl_gui_alv_grid.



START-OF-SELECTION.
  SELECT * FROM zzp_malzeme INTO TABLE gt_zzp_malzeme.

  CALL SCREEN   0100.

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
  CREATE OBJECT go_container
    EXPORTING
      container_name = 'CC_ALV'.

  CREATE OBJECT go_grid
    EXPORTING
      i_parent = go_container.


  CALL METHOD go_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZZP_MALZEME'
    CHANGING
      it_outtab        = gt_zzp_malzeme.

ENDMODULE.


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&BCK' OR '&EXT'.
      LEAVE PROGRAM.
  ENDCASE.
ENDMODULE.
