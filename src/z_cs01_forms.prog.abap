*----------------------------------------------------------------------*
***INCLUDE Z_CS01_FORMS.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_header .

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr        = '01'
      object             = 'ZBOMNR'
    IMPORTING
      number             = gv_stko-stlnr
    EXCEPTIONS
      interval_not_found = 1.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    MESSAGE 'NUMARA ÜRETİLEMEDİ' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.


  gv_stko-matnr = gv_matnr.
  gv_stko-stlan = gv_stlan.
  gv_stko-wrkan = gv_plant.
  gv_stko-stlal = gv_stlal.
  gv_stko-datuv = gv_datuv.
  gv_stko-stlty = 'M'.
  gv_stko-datub = '20301231'.
  gv_stko-bmeng = '1'.
  gv_stko-bmein = 'EA'.
  gv_stko-bmeng = '1'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_HEADER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM check_header.

  DATA lv_rc  TYPE i.
  DATA lv_msg TYPE string.

  "--------------------------------------------------
  " Function Module çağrısı
  "--------------------------------------------------
  CALL FUNCTION 'Z_CHECK_HEADER'
    EXPORTING
      iv_matnr   = gv_matnr
      iv_plant   = gv_plant
      iv_stlan   = gv_stlan
      iv_stlal   = gv_stlal
      iv_datuv   = gv_datuv
    IMPORTING
      ev_rc      = lv_rc
      ev_message = lv_msg.

  "--------------------------------------------------
  " Global değişkenlere aktar
  "--------------------------------------------------
  gv_rc  = lv_rc.
  gv_msg = lv_msg.
  "--------------------------------------------------
  " Hata varsa popup göster ve formdan çık
  "--------------------------------------------------

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BOM_EXISTS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM check_bom_exists .
  DATA lv_count TYPE i.

  SELECT COUNT(*) INTO lv_count
    FROM zzp_stko
    WHERE matnr = gv_matnr.

  IF lv_count > 0.
    MESSAGE  'Bu malzemenin zaten bir BOM''u    mevcut, yeni BOM oluşturulamaz.' TYPE 'S' DISPLAY LIKE 'E'.  .

    sy-subrc = 4.
  ELSE.
    sy-subrc = 0.
  ENDIF.

ENDFORM.



*--- FORM ---*
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
*&---------------------------------------------------------------------*
*& Form CREATE_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM create_alv .

  CREATE OBJECT g_container
    EXPORTING
      container_name = 'CCL_ALV_ITEM'.

  CREATE OBJECT g_grid
    EXPORTING
      i_parent = g_container.

  PERFORM build_fieldcatalog.

  gs_layout-edit = 'X'.
  gs_layout-zebra = 'X'.

  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_modified.
  CALL METHOD g_grid->register_edit_event
    EXPORTING
      i_event_id = cl_gui_alv_grid=>mc_evt_enter.

  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZZP_STPO'
    CHANGING
      it_outtab        = gt_stpo
      it_fieldcatalog  = gt_fieldcat.

  CREATE OBJECT go_alv_events TYPE lcl_alv_events.
  SET HANDLER go_alv_events->handle_data_changed FOR g_grid.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fieldcatalog .


  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'ZZP_STPO'
    CHANGING
      ct_fieldcat      = gt_fieldcat
    EXCEPTIONS
      OTHERS           = 3.
  LOOP AT gt_fieldcat INTO gs_fieldcat.


    CASE gs_fieldcat-fieldname.

      WHEN 'STLNR'.
        gs_fieldcat-no_out = 'X'.
        gs_fieldcat-tech   = 'X'.

      WHEN 'STPOZ'. " Item numarası
        gs_fieldcat-key  = 'X'.
        gs_fieldcat-edit = ''.

      WHEN 'MATNR'. " Malzeme
        gs_fieldcat-edit       = 'X'.
        gs_fieldcat-f4availabl = 'X'.   " Search help aktif

      WHEN 'STLTY'. " BOM kategorisi
        gs_fieldcat-edit       = 'X'.
        gs_fieldcat-f4availabl = 'X'.

      WHEN 'POSTP'. " Item category
        gs_fieldcat-edit       = 'X'.

        gs_fieldcat-f4availabl = 'X'.   " F4 aktif
*        gs_fieldcat-ref_table  = 'ZZP_ITEMCAT'. " Geçerli değerler için tablo
*        gs_fieldcat-ref_field  = 'POSTP'.
        gs_fieldcat-scrtext_l ='Item category'.
        gs_fieldcat-scrtext_m ='Item cat'.
        gs_fieldcat-scrtext_m ='Ict.'.


      WHEN 'MENGE'. " Quantity
        gs_fieldcat-edit       = 'X'.
        gs_fieldcat-f4availabl = 'X'.

      WHEN 'MEINS'. " UoM
        gs_fieldcat-edit      = ' '.  " readonly   " kesinlikle edit kapalı
        gs_fieldcat-outputlen = 3.
        gs_fieldcat-ref_table = 'ZZP_MALZEME'.   " referans tablo
        gs_fieldcat-ref_field = 'MEINS'.  " referans alan


      WHEN 'DATUV' OR 'DATUB'. " Valid from/to
        gs_fieldcat-edit = 'X'.

      WHEN OTHERS.
        gs_fieldcat-edit = ''.

    ENDCASE.

    MODIFY gt_fieldcat FROM gs_fieldcat.
  ENDLOOP.


  IF sy-subrc <> 0.
    MESSAGE 'Field catalog oluşturulamadı' TYPE 'S' DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.
FORM init_alv_rows USING p_rows TYPE i.
  DATA lv_counter TYPE i.
  DO p_rows TIMES.
    CLEAR gs_stpo.
    lv_counter = sy-index * 10.
    gs_stpo-stpoz = lv_counter.
    APPEND gs_stpo TO gt_stpo.
  ENDDO.
  CALL METHOD g_grid->refresh_table_display.
ENDFORM.

FORM add_empty_rows_auto USING p_rows TYPE i.
  DATA lv_counter TYPE i.
  LOOP AT gt_stpo INTO gs_stpo.
    lv_counter = gs_stpo-stpoz.
  ENDLOOP.
  DO p_rows TIMES.
    CLEAR gs_stpo.
    lv_counter = lv_counter + 10.
    gs_stpo-stpoz = lv_counter.
    APPEND gs_stpo TO gt_stpo.
  ENDDO.
ENDFORM.

*------------------------------------------------------------
* ALV ROW CHECK (MATNR -> MEINS + otomatik satır ekle)
*------------------------------------------------------------
FORM check_alv_rows.
  DATA lv_last_index TYPE i.
  lv_last_index = lines( gt_stpo ).

  LOOP AT gt_stpo INTO gs_stpo.
    IF gs_stpo-matnr IS NOT INITIAL.
      SELECT SINGLE meins INTO gs_stpo-meins FROM zzp_malzeme WHERE matnr = gs_stpo-matnr.
      MODIFY gt_stpo FROM gs_stpo.
    ENDIF.
  ENDLOOP.

  " Son satır doluysa 10 yeni satır ekle
  READ TABLE gt_stpo INDEX lv_last_index INTO gs_stpo.
  IF gs_stpo-matnr IS NOT INITIAL OR gs_stpo-postp IS NOT INITIAL OR gs_stpo-menge IS NOT INITIAL.
    PERFORM add_empty_rows_auto USING 10.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display.
ENDFORM.

*------------------------------------------------------------
* ITEM INSERT (SAVE)
*------------------------------------------------------------
FORM save_items .
  DATA: lv_error TYPE string,
        lv_count TYPE i.

  lv_count = 0.
  LOOP AT gt_stpo INTO gs_stpo.
    IF gs_stpo-matnr IS INITIAL.
      lv_count = lv_count + 1.
    ENDIF.
  ENDLOOP.

  IF lv_count <> 0.
    MESSAGE 'Lütfen veri giriniz, tablo boş.' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  "--- STKO insert (BOM başlığı) ---
  INSERT INTO zzp_stko VALUES gv_stko.
  IF sy-subrc <> 0.
    lv_error = 'STKO insert hatası, işlem geri alındı'.
    ROLLBACK WORK.
    MESSAGE lv_error TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  "--- STPO insert (alt satırlar) ---
  LOOP AT gt_stpo INTO gs_stpo.
    TRY.
        IF gs_stpo-matnr IS INITIAL.
          CONTINUE.
        ENDIF.

        "Malzeme birimini al
        SELECT SINGLE meins
          INTO gs_stpo-meins
          FROM zzp_malzeme
          WHERE matnr = gs_stpo-matnr.
        IF sy-subrc <> 0.
          lv_error = |Malzeme { gs_stpo-matnr } bulunamadı, işlem geri alındı|.
          ROLLBACK WORK.
          MESSAGE lv_error TYPE 'S' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

        "Alt satırın STKO ile bağlantısı
        gs_stpo-stlnr = gv_stko-stlnr.

        "STPO insert
        INSERT INTO zzp_stpo VALUES gs_stpo.
        IF sy-subrc <> 0.
          lv_error = 'STPO insert hatası, işlem geri alındı'.
          ROLLBACK WORK.
          MESSAGE lv_error TYPE 'S' DISPLAY LIKE 'E'.
          EXIT.
        ENDIF.

    ENDTRY.
  ENDLOOP.

  "--- Her şey başarılıysa commit ---
  COMMIT WORK.
    IF sy-subrc = 0.
    MESSAGE 'BOM başarıyla kaydedildi.' TYPE 'S'.

    PERFORM clear_all_globals.
    SET SCREEN 0.
    ENDIF.

ENDFORM.

*------------------------------------------------------------
* DELETE PLACEHOLDER
*------------------------------------------------------------
FORM delete_selected_rows.
  MESSAGE 'Delete fonksiyonu henüz eklenmedi' TYPE 'I'.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ALL_GLOBALS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM clear_all_globals .

  CLEAR: gv_matnr,
        gv_plant,
        gv_stlan,
        gv_stlal,
        gv_datuv,
        gv_msg,
        gv_rc,
        gv_stko,
        gv_malz,
        gv_plan_text,
        gv_stlal_text,
        gv_matnr_text,
        gs_data,
        gs_stpo,
        gs_fieldcat,
        gs_layout,
        g_grid,
        g_container.

  REFRESH: gt_zzp_stpo,
           gt_stpo,
           gt_fieldcat.

  " ALV komponentlerini temizle (gerekirse)
  IF g_grid IS BOUND.
    CALL METHOD g_grid->free.
    FREE g_grid.
  ENDIF.

  IF g_container IS BOUND.
    CALL METHOD g_container->free.
    FREE g_container.
  ENDIF.
ENDFORM.
