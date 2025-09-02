*&---------------------------------------------------------------------*
*& Include          Z_CS03_TOP
*&---------------------------------------------------------------------*

DATA: gv_matnr     TYPE matnr,
      gv_plant     TYPE zde_wrakan,
      gv_stlan     TYPE zde_stlan,
      gv_stlal     TYPE zde_stlat,
      gv_datuv     TYPE datuv,
      gv_rc        TYPE i,
      gv_msg       TYPE string.

DATA: gv_stko      TYPE zzp_stko,
      gv_malz      TYPE zzp_malzeme.

DATA: gv_plan_text TYPE ddtext,
      gv_stlal_text TYPE ddtext,
      gv_matnr_text TYPE maktx.

" Item Structure
TYPES: BEGIN OF zzp_stpo_data,
         matnr TYPE matnr,
         stlnr TYPE zde_stnum,
         stpoz TYPE cim_count,
         stlty TYPE zde_stlty,
         postp TYPE postp,
         menge TYPE menge_d,
         meins TYPE meins,
       END OF zzp_stpo_data.

" Item Data Table
DATA: gt_stpo TYPE STANDARD TABLE OF zzp_stpo,
      gs_stpo TYPE zzp_stpo_data.

" ALV Components
DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_fieldcat TYPE lvc_s_fcat,
      gs_layout   TYPE lvc_s_layo,
      g_grid      TYPE REF TO cl_gui_alv_grid,
      g_container TYPE REF TO cl_gui_custom_container.
