*----------------------------------------------------------------------*
***INCLUDE Z_CS03_FORMS.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- RC
*&---------------------------------------------------------------------*
FORM check_header.

  DATA lv_rc  TYPE i.
  DATA lv_msg TYPE string.

  "--------------------------------------------------
  " Function Module çağrısı
  "--------------------------------------------------
  CALL FUNCTION 'Z_CHECK_HEADER'
    EXPORTING
      IV_MATNR = gv_matnr
      IV_PLANT = gv_plant
      IV_STLAN = gv_stlan
      IV_STLAL = gv_stlal
      IV_DATUV = gv_datuv
    IMPORTING
      EV_RC      = lv_rc
      EV_MESSAGE = lv_msg.

  "--------------------------------------------------
  " Global değişkenlere aktar
  "--------------------------------------------------
  gv_rc  = lv_rc.
  gv_msg = lv_msg.

  "--------------------------------------------------
  " Hata varsa popup göster ve formdan çık
  "--------------------------------------------------
  IF lv_rc = 4.
    MESSAGE lv_msg TYPE 'S'.
    EXIT.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
*& Form GET_VALUE_RANGE_TEXT
*----------------------------------------------------------------------*
FORM get_value_range_text
  USING    pv_value TYPE dd07l-domvalue_l
           pv_domname TYPE dd03l-domname
  CHANGING
           cv_text TYPE ddtext.

  DATA lv_dd07v_wa TYPE dd07v.
  DATA lv_rc      TYPE sy-subrc.

  CLEAR cv_text.

  " Fonksiyon çağrısı
  CALL FUNCTION 'DD_DOMVALUE_TEXT_GET'
    EXPORTING
      domname  = pv_domname
      value    = pv_value
      langu    = sy-langu
    IMPORTING
      dd07v_wa = lv_dd07v_wa
      rc       = lv_rc.

  IF lv_rc = 0.
    cv_text = lv_dd07v_wa-ddtext.
  ELSE.
    cv_text = 'Bulunamadı'.
  ENDIF.

ENDFORM.

*----------------------------------------------------------------------*
*& Form GET_DATA
*----------------------------------------------------------------------*
FORM get_data .

  CLEAR gt_stpo.

  SELECT SINGLE * FROM zzp_stko INTO @gv_stko
    WHERE matnr = @gv_matnr AND wrkan = @gv_plant
    AND   stlan = @gv_stlan AND stlal = @gv_stlal.

  IF sy-subrc <> 0.
    MESSAGE 'Girilen kriterlere göre BOM header bulunamadı' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT * FROM zzp_stpo INTO TABLE @gt_stpo
     WHERE stlnr = @gv_stko-stlnr .

ENDFORM.

*----------------------------------------------------------------------*
*& Form CREATE_ALV
*----------------------------------------------------------------------*
FORM create_alv .

  CREATE OBJECT g_container
    EXPORTING container_name = 'CCL_ALV_ITEM'.

  CREATE OBJECT g_grid
    EXPORTING i_parent = g_container.

* PERFORM build_field_catalog. "Opsiyonel
  PERFORM display_alv.

ENDFORM.

*----------------------------------------------------------------------*
*& Form BUILD_FIELD_CATALOG
*----------------------------------------------------------------------*
FORM build_field_catalog .
" Field catalog oluşturma burada yapılabilir
ENDFORM.

*----------------------------------------------------------------------*
*& Form DISPLAY_ALV
*----------------------------------------------------------------------*
FORM display_alv .
  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZZP_STPO'
    CHANGING
      it_outtab        = gt_stpo.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CLEAR_ALL_GLOBALS
*&---------------------------------------------------------------------*
FORM clear_all_globals.

  " Basit veri tiplerini temizle
  CLEAR gv_matnr.
  CLEAR gv_plant.
  CLEAR gv_stlan.
  CLEAR gv_stlal.
  CLEAR gv_datuv.
  CLEAR gv_rc.
  CLEAR gv_msg.

  CLEAR gv_stko.
  CLEAR gv_malz.

  CLEAR gv_plan_text.
  CLEAR gv_stlal_text.
  CLEAR gv_matnr_text.

  " ALV tablolarını temizle
  CLEAR gt_stpo.
  CLEAR gs_stpo.

  " ALV fieldcatalog ve layout
  CLEAR gt_fieldcat.
  CLEAR gs_fieldcat.
  CLEAR gs_layout.

  " ALV ve container objelerini free et ve referansları temizle
  IF g_grid IS BOUND.
    CALL METHOD g_grid->free.
    FREE g_grid.
  ENDIF.

  IF g_container IS BOUND.
    CALL METHOD g_container->free.
    FREE g_container.
  ENDIF.

ENDFORM.
