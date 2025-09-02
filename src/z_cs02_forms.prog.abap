*----------------------------------------------------------------------*
***INCLUDE Z_CS02_FORMS.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_HEADER
*&---------------------------------------------------------------------*
FORM check_header.
  DATA lv_rc  TYPE i.
  DATA lv_msg TYPE string.

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

  gv_rc  = lv_rc.
  gv_msg = lv_msg.

  IF lv_rc = 4.
    MESSAGE lv_msg TYPE 'S' DISPLAY LIKE 'E'.
    sy-subrc = 4.
    RETURN.
  ELSE.
    sy-subrc = 0.
  ENDIF.

ENDFORM.


*&---------------------------------------------------------------------*
*& Form GET_VALUE_RANGE_TEXT
*&---------------------------------------------------------------------*
FORM get_value_range_text
  USING    pv_value   TYPE dd07l-domvalue_l
           pv_domname TYPE dd03l-domname
  CHANGING
           cv_text    TYPE ddtext.

  DATA lv_dd07v_wa TYPE dd07v.
  DATA lv_rc      TYPE sy-subrc.

  CLEAR cv_text.

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
*& Form GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.
  CLEAR gt_stpo.

  SELECT SINGLE *
    FROM zzp_stko
    INTO @gv_stko
    WHERE matnr = @gv_matnr
      AND wrkan = @gv_plant
      AND stlan = @gv_stlan
      AND stlal = @gv_stlal.

  IF sy-subrc <> 0.
    MESSAGE 'Girilen kriterlere göre BOM header bulunamadı' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  SELECT *
    FROM zzp_stpo
    INTO TABLE @gt_stpo
    WHERE stlnr = @gv_stko-stlnr.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CREATE_ALV
*&---------------------------------------------------------------------*
FORM create_alv.
  " Container ve ALV grid yarat
  CREATE OBJECT g_container
    EXPORTING
      container_name = 'CCL_ALV_ITEM'.

  CREATE OBJECT g_grid
    EXPORTING
      i_parent = g_container.

  " Field catalog oluştur
  PERFORM build_field_catalog.

  " Layout ayarları
* gs_layout-edit  = 'X'.
  gs_layout-zebra = 'X'. " Alternating row colors

  " Edit event register
  CREATE OBJECT go_alv_events TYPE lcl_alv_events.
  SET HANDLER go_alv_events->handle_data_changed FOR g_grid.

  " ALV göster
  CALL METHOD g_grid->set_table_for_first_display
    EXPORTING
      i_structure_name = 'ZZP_STPO'
      is_layout        = gs_layout
    CHANGING
      it_outtab        = gt_stpo
      it_fieldcatalog  = gt_fieldcat.

ENDFORM.




*&---------------------------------------------------------------------*
*& Form BUILD_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM build_field_catalog.
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

      WHEN 'STPOZ'.
        gs_fieldcat-key = 'X'.

      WHEN 'MATNR'.
        gs_fieldcat-edit       = 'X'.
        gs_fieldcat-f4availabl = 'X'.

      WHEN 'STLTY' OR 'POSTP' OR 'MENGE' OR 'DATUV' OR 'DATUB'.
        gs_fieldcat-edit       = 'X'.
        gs_fieldcat-f4availabl = 'X'.

      WHEN 'MEINS'.
        gs_fieldcat-edit      = ''.  " Read-only
        gs_fieldcat-ref_table = 'ZZP_MALZEME'.
        gs_fieldcat-ref_field = 'MEINS'.

      WHEN OTHERS.
        gs_fieldcat-edit = ''.
    ENDCASE.
    MODIFY gt_fieldcat FROM gs_fieldcat.
  ENDLOOP.

  IF sy-subrc <> 0.
    MESSAGE 'Field catalog oluşturulamadı' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form DISPLAY_ALV
*&---------------------------------------------------------------------*
*FORM display_alv.
*  DATA gs_layout TYPE lvc_s_layo.
*  gs_layout-edit = 'X'.
*
*  CALL METHOD g_grid->set_table_for_first_display
*    EXPORTING
*      i_structure_name = 'ZZP_STPO'
*      is_layout        = gs_layout
*    CHANGING
*      it_outtab        = gt_stpo.
*ENDFORM.

*&---------------------------------------------------------------------*
*& Form ADD_EMPTY_ROWS_last
*&---------------------------------------------------------------------*
FORM add_empty_rows_after_last USING p_rows TYPE i.
  DATA lv_last_counter TYPE i.
  DATA ls_stpo        TYPE zzp_stpo_data.

  LOOP AT gt_stpo INTO ls_stpo.
    IF ls_stpo-stpoz > lv_last_counter.
      lv_last_counter = ls_stpo-stpoz.
    ENDIF.
  ENDLOOP.

  DO p_rows TIMES.
    CLEAR ls_stpo.
    lv_last_counter = lv_last_counter + 1.
    ls_stpo-stpoz = lv_last_counter.
    APPEND ls_stpo TO gt_stpo.
  ENDDO.

  CALL METHOD g_grid->refresh_table_display.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form CHECK_ALV_ROWS
*&---------------------------------------------------------------------*
FORM check_alv_rows.
  DATA lv_last_index TYPE i.
  lv_last_index = lines( gt_stpo ).

  LOOP AT gt_stpo INTO gs_stpo.
    IF gs_stpo-matnr IS NOT INITIAL.
      SELECT SINGLE meins INTO gs_stpo-meins
        FROM zzp_malzeme
        WHERE matnr = gs_stpo-matnr.
      MODIFY gt_stpo FROM gs_stpo.
    ENDIF.
  ENDLOOP.

  " Son satır doluysa 10 yeni satır ekle
  READ TABLE gt_stpo INDEX lv_last_index INTO gs_stpo.
  IF gs_stpo-matnr IS NOT INITIAL OR gs_stpo-postp IS NOT INITIAL OR gs_stpo-menge IS NOT INITIAL.
    PERFORM add_empty_rows_after_last USING 10.
  ENDIF.

  CALL METHOD g_grid->refresh_table_display.
  CLEAR gs_row_id.
  CLEAR gs_col_id.

  " Satır ve sütunu sıfır verirsen ALV açıldığında hiç hücre seçilmez
  gs_row_id-row_id     = 0.
  gs_col_id-fieldname  = ''.

  CALL METHOD g_grid->set_current_cell_via_id
    EXPORTING
      is_row_no    = gs_row_id
      is_column_id = gs_col_id.


ENDFORM.

*&---------------------------------------------------------------------*
*& Form DELETE_BOM
*&---------------------------------------------------------------------*
FORM delete_bom.
  DATA: lt_stko TYPE STANDARD TABLE OF zzp_stko,
        lt_stpo TYPE STANDARD TABLE OF zzp_stpo,
        lv_answer TYPE c.

  PERFORM check_header.

  IF gv_rc = 4.
    MESSAGE gv_msg TYPE 'E'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar      = 'BOM Silme Onayı'
      text_question = |{ gv_matnr } numaralı BOM tamamen silinsin mi?|
      text_button_1 = 'Evet'
      text_button_2 = 'Hayır'
    IMPORTING
      answer        = lv_answer.

  IF lv_answer = '1'.

    " --- STPO kayıtlarını MATNR bazlı seç ve sil ---
    SELECT * FROM zzp_stpo
      INTO TABLE lt_stpo
      WHERE matnr = gv_matnr.

    DELETE zzp_stpo FROM TABLE lt_stpo.
    MESSAGE |STPO'dan { sy-dbcnt } satır silindi.| TYPE 'S'.

    " --- STKO kayıtlarını MATNR bazlı seç ve sil ---
    SELECT * FROM zzp_stko
      INTO TABLE lt_stko
      WHERE matnr = gv_matnr.

    DELETE zzp_stko FROM TABLE lt_stko.
    MESSAGE |STKO'dan { sy-dbcnt } satır silindi.| TYPE 'S'.

    COMMIT WORK.

  ENDIF.
ENDFORM.



*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SAVE_DATA
*&---------------------------------------------------------------------*
FORM save_data.
  " ALV buffer’daki değişiklikleri tabloya aktar
  g_grid->check_changed_data( ).

  " Update işlemini çağır
  PERFORM update_bom.

  " Eğer update başarılıysa
  IF sy-subrc = 0.
    MESSAGE 'BOM başarıyla güncellendi.' TYPE 'S'.
    " Global verileri temizle
    PERFORM clear_all_globals.
  ENDIF.


ENDFORM.


*&---------------------------------------------------------------------*
*& Form UPDATE_BOM
*&---------------------------------------------------------------------*
FORM update_bom .

  DATA: lt_stpo_db   TYPE STANDARD TABLE OF zzp_stpo,
        ls_stpo_db   TYPE zzp_stpo,
        ls_stpo      TYPE zzp_stpo_data,
        lt_insert    TYPE STANDARD TABLE OF zzp_stpo,
        lt_update    TYPE STANDARD TABLE OF zzp_stpo,
        ls_stpo_ins  TYPE zzp_stpo,
        lv_max_stpoz TYPE cim_count.


  SELECT * INTO TABLE lt_stpo_db
    FROM zzp_stpo
    WHERE stlnr = gv_stko-stlnr.


  LOOP AT gt_stpo INTO ls_stpo.
    IF ls_stpo-matnr IS INITIAL.
      CONTINUE.
    ENDIF.

    " STLNR doldur
    IF ls_stpo-stlnr IS INITIAL.
      ls_stpo-stlnr = gv_stko-stlnr.
    ENDIF.


    READ TABLE lt_stpo_db INTO ls_stpo_db
         WITH KEY stlnr = ls_stpo-stlnr
                  stpoz = ls_stpo-stpoz
         TRANSPORTING NO FIELDS.

    IF sy-subrc = 0.

      CLEAR ls_stpo_ins.
      MOVE-CORRESPONDING ls_stpo TO ls_stpo_ins.
      APPEND ls_stpo_ins TO lt_update.
    ELSE.

      IF ls_stpo-stpoz IS INITIAL.
        SELECT MAX( stpoz ) INTO lv_max_stpoz
          FROM zzp_stpo
          WHERE stlnr = ls_stpo-stlnr.
        IF sy-subrc <> 0.
          lv_max_stpoz = 0.
        ENDIF.
        ls_stpo-stpoz = lv_max_stpoz + 1.
      ENDIF.

      CLEAR ls_stpo_ins.
      MOVE-CORRESPONDING ls_stpo TO ls_stpo_ins.
      APPEND ls_stpo_ins TO lt_insert.
    ENDIF.

  ENDLOOP.


  LOOP AT lt_update INTO ls_stpo_ins.
    UPDATE zzp_stpo
   SET matnr = ls_stpo_ins-matnr
       stlty = ls_stpo_ins-stlty
       postp = ls_stpo_ins-postp
       menge = ls_stpo_ins-menge
       meins = ls_stpo_ins-meins
       datuv = ls_stpo_ins-datuv
       datub = ls_stpo_ins-datub
 WHERE stlnr = ls_stpo_ins-stlnr
   AND stpoz = ls_stpo_ins-stpoz.

    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE e398(00) WITH |UPDATE failed: STPOZ { ls_stpo_ins-stpoz }|.
    ENDIF.
  ENDLOOP.

  IF lt_insert IS NOT INITIAL.
    INSERT zzp_stpo FROM TABLE lt_insert.
    IF sy-subrc <> 0.
      ROLLBACK WORK.
      MESSAGE e398(00) WITH 'INSERT failed!'.
    ENDIF.
  ENDIF.

  LOOP AT lt_stpo_db INTO ls_stpo_db.
    READ TABLE gt_stpo INTO ls_stpo
         WITH KEY stlnr = ls_stpo_db-stlnr
                  stpoz = ls_stpo_db-stpoz.
    IF sy-subrc <> 0.
      DELETE FROM zzp_stpo
        WHERE stlnr = ls_stpo_db-stlnr
          AND stpoz = ls_stpo_db-stpoz.
      IF sy-subrc <> 0.
        ROLLBACK WORK.
        MESSAGE e398(00) WITH |DELETE failed: STPOZ { ls_stpo_db-stpoz }|.
      ENDIF.
    ENDIF.
  ENDLOOP.


  COMMIT WORK.

  g_grid->refresh_table_display( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CLEAR_ALL_GLOBALS
*&---------------------------------------------------------------------*
*& Açıklama: Tüm ALV ve global veri tablolarını temizler
*&---------------------------------------------------------------------*
FORM clear_all_globals.

  " ALV item tabloları ve yapılarını temizle
  CLEAR gt_stpo.
  CLEAR gs_stpo.
  CLEAR gs_row_id.
  CLEAR gs_col_id.

  " Malzeme tablosu ve yapılarını temizle
  CLEAR gt_malz.
  CLEAR gv_malz.

  " Header ve selection screen verilerini temizle
  CLEAR gv_stko.
  CLEAR gv_matnr.
  CLEAR gv_plant.
  CLEAR gv_stlan.
  CLEAR gv_stlal.
  CLEAR gv_datuv.
  CLEAR gv_rc.
  CLEAR gv_msg.
  CLEAR gv_plan_text.
  CLEAR gv_stlal_text.
  CLEAR gv_matnr_text.

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
