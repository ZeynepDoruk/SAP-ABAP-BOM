*&---------------------------------------------------------------------*
*& Include         TOP
*&-------- Z_CS01_-------------------------------------------------------------*


DATA: gv_matnr TYPE matnr,
      gv_plant TYPE zde_wrakan,
      gv_stlan TYPE zde_stlan,
      gv_stlal TYPE zde_stlat,
      gv_datuv TYPE datuv,
      gv_msg TYPE string,
      gv_rc type i.

DATA: gv_stko TYPE zzp_stko,
      gv_malz TYPE zzp_malzeme.

DATA: gv_plan_text  TYPE ddtext,
      gv_stlal_text TYPE ddtext,
      gv_matnr_text TYPE maktx.


TYPES: BEGIN OF ZZP_STPO_data,
         MATNR TYPE MATNR,
         STLNR TYPE ZDE_STNUM,
         STPOZ  TYPE CIM_COUNT,
         STLTY TYPE ZDE_STLTY,
         POST  TYPE POSTP,
         menge  TYPE menge_d,
         MEINS TYPE MEINS,

       END OF ZZP_STPO_data.

DATA: gt_ZZP_STPO TYPE STANDARD TABLE OF ZZP_STKO,
      gs_data TYPE ZZP_STPO_data.

DATA: gt_stpo      TYPE STANDARD TABLE OF zzp_stpo,
      gs_stpo      TYPE zzp_stpo,
      gt_fieldcat  TYPE lvc_t_fcat,
      gs_fieldcat  TYPE lvc_s_fcat,
      gs_layout    TYPE lvc_s_layo,
      g_grid       TYPE REF TO cl_gui_alv_grid,
      g_container  TYPE REF TO cl_gui_custom_container.




CLASS lcl_alv_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
ENDCLASS.

CLASS lcl_alv_events IMPLEMENTATION.
METHOD handle_data_changed.
  DATA: ls_row TYPE lvc_s_modi,
        lv_matnr TYPE matnr,
        lv_meins TYPE meins.

  LOOP AT er_data_changed->mt_good_cells INTO ls_row.
    IF ls_row-fieldname = 'MATNR'.

      " Kullanıcının girdiği yeni değer buradan geliyor
      lv_matnr = ls_row-value.

      " Malzeme tablosundan MEINS çek
      SELECT SINGLE meins
        INTO lv_meins
        FROM zzp_malzeme
        WHERE matnr = lv_matnr.

      " ALV hücresine direkt yaz (internal table update gerekmez)
      CALL METHOD er_data_changed->modify_cell
        EXPORTING
          i_row_id    = ls_row-row_id
          i_fieldname = 'MEINS'
          i_value     = lv_meins.

      " Internal table da güncellensin istiyorsan:
      READ TABLE gt_stpo INTO gs_stpo INDEX ls_row-row_id.
      IF sy-subrc = 0.
        gs_stpo-matnr = lv_matnr.
        gs_stpo-meins = lv_meins.
        MODIFY gt_stpo FROM gs_stpo INDEX ls_row-row_id.
      ENDIF.

    ENDIF.
  ENDLOOP.

  " Satır doluysa yeni satır ekleme kontrolü
  READ TABLE gt_stpo INDEX lines( gt_stpo ) INTO DATA(gs_last).
  IF gs_last-matnr IS NOT INITIAL
  OR gs_last-postp IS NOT INITIAL
  OR gs_last-menge IS NOT INITIAL.
    PERFORM add_empty_rows_auto USING 10.
  ENDIF.
ENDMETHOD.

ENDCLASS.


DATA go_alv_events TYPE REF TO lcl_alv_events.
