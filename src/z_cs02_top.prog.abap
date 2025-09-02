*&---------------------------------------------------------------------*
*& Include          Z_CS02_TOP
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Include          Z_CS03_TOP
*&---------------------------------------------------------------------*

DATA: gv_matnr TYPE matnr,
      gv_plant TYPE zde_wrakan,
      gv_stlan TYPE zde_stlan,
      gv_stlal TYPE zde_stlat,
      gv_datuv TYPE datuv,
      gv_rc    TYPE i,
      gv_msg   TYPE string.

DATA: gv_stko TYPE zzp_stko,
      gv_malz TYPE zzp_malzeme.

DATA: gv_plan_text  TYPE ddtext,
      gv_stlal_text TYPE ddtext,
      gv_matnr_text TYPE maktx.

" Item Structure
TYPES: BEGIN OF zzp_stpo_data,
         mandt TYPE mandt,
         stlnr TYPE zde_stnum,
         stpoz TYPE cim_count,
         matnr TYPE matnr,
         stlty TYPE zde_stlty,
         postp TYPE zde_postp,
         menge TYPE menge_d,
         meins TYPE meins,
         datuv TYPE datuv,
         datub TYPE datub,
       END OF zzp_stpo_data.

DATA: gt_stpo TYPE STANDARD TABLE OF zzp_stpo_data,
      gs_stpo TYPE zzp_stpo.

DATA: gs_row_id TYPE lvc_s_roid,
      gs_col_id TYPE lvc_s_col.


" ALV Components
DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat,
      gs_layout   TYPE lvc_s_layo,
      g_grid      TYPE REF TO cl_gui_alv_grid,
      g_container TYPE REF TO cl_gui_custom_container.

DATA: gt_malz TYPE STANDARD TABLE OF zzp_malzeme.


CLASS lcl_alv_events DEFINITION.
  PUBLIC SECTION.
    METHODS:
      handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid
        IMPORTING er_data_changed.
ENDCLASS.

CLASS lcl_alv_events IMPLEMENTATION.
  METHOD handle_data_changed.
    DATA: ls_row   TYPE lvc_s_modi,
          ls_stpo  TYPE zzp_stpo_data,
          lv_meins TYPE meins.

    " Sadece gerçekten değiştirilen hücreleri işle
    LOOP AT er_data_changed->mt_good_cells INTO ls_row.
      " MATNR alanı değişmişse
      IF ls_row-fieldname = 'MATNR'.
        " Yeni MATNR değeri
        READ TABLE gt_stpo INTO ls_stpo INDEX ls_row-row_id.
        IF sy-subrc = 0.
          ls_stpo-matnr = ls_row-value.

          " MEINS otomatik getir
          SELECT SINGLE meins INTO lv_meins
            FROM zzp_malzeme
            WHERE matnr = ls_stpo-matnr.

          ls_stpo-meins = lv_meins.
          MODIFY gt_stpo FROM ls_stpo INDEX ls_row-row_id.

          " ALV hücresini güncelle
          CALL METHOD er_data_changed->modify_cell
            EXPORTING
              i_row_id    = ls_row-row_id
              i_fieldname = 'MEINS'
              i_value     = lv_meins.
        ENDIF.
      ENDIF.
    ENDLOOP.

    " Son satır doluysa yeni satır ekle
    READ TABLE gt_stpo INDEX lines( gt_stpo ) INTO ls_stpo.
    IF ls_stpo-matnr IS NOT INITIAL
       OR ls_stpo-postp IS NOT INITIAL
       OR ls_stpo-menge IS NOT INITIAL.
      PERFORM add_empty_rows_after_last USING 10.
    ENDIF.

    CALL METHOD g_grid->refresh_table_display.

  ENDMETHOD.
ENDCLASS.

DATA go_alv_events TYPE REF TO lcl_alv_events.
