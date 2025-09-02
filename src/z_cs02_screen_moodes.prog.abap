*&---------------------------------------------------------------------*
*& Include          Z_CS02_SCREEN_MOODES
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  " Menü durumunu ayarla
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.

*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  CASE sy-ucomm.

    WHEN '&BCK' OR '&EXT'.
      " Önceki ekrana dön
      SET SCREEN 0.
    WHEN '&OK'.
      PERFORM check_header.
      IF sy-subrc = 0.
*        PERFORM get_data.
        CALL SCREEN 0200.
      ELSE.
        MESSAGE  gv_msg  TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
    WHEN '&DEL'.
      " BOM silme
      PERFORM delete_bom.

  ENDCASE.

ENDMODULE.

*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  " Menü durumunu ayarla
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.

  " Geçici değişkenler
  DATA lv_plan_text TYPE ddtext.
  DATA lv_stlal_text TYPE ddtext.
  DATA lv_matnr_text TYPE string.
  DATA lv_plant_dd07l TYPE dd07l-domvalue_l.
  DATA lv_stlal_dd07l TYPE dd07l-domvalue_l.

  " Kod değerlerini ata
  lv_plant_dd07l = gv_plant.
  lv_stlal_dd07l = gv_stlal.

  " Textleri al
  PERFORM get_value_range_text USING lv_plant_dd07l 'Z_DM_WERKS' CHANGING lv_plan_text.
  PERFORM get_value_range_text USING lv_stlal_dd07l 'ZDM_ALTNR' CHANGING lv_stlal_text.

  " Malzeme açıklamasını al
  SELECT SINGLE maktx INTO lv_matnr_text
    FROM zzp_malzeme
    WHERE matnr = gv_matnr.
  IF sy-subrc <> 0.
    lv_matnr_text = 'Bulunamadı'.
  ENDIF.

  " Global değişkenlere ata
  gv_plan_text = lv_plan_text.
  gv_stlal_text = lv_stlal_text.
  gv_matnr_text = lv_matnr_text.

  " Var olan itemleri al
  PERFORM get_data.


  " ALV container oluştur ve göster
  IF g_container IS INITIAL.
    PERFORM create_alv.
    PERFORM add_empty_rows_after_last USING 10.
  ENDIF.

ENDMODULE.


*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0200 INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  DATA lv_answer TYPE c.
  CASE sy-ucomm.
      IF g_grid IS BOUND.
        CALL METHOD g_grid->check_changed_data.
      ENDIF.

    WHEN '&BCK' OR '&EXT'.
      " Önceki ekrana dön
      SET SCREEN 0.

    WHEN  '&SAVE'.

      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar              = 'ONAY  '
          text_question         = ' Emin misiniz ? değişiklikler kaydedilecektir ve geri alınamaz'
          text_button_1         = 'evet '
          icon_button_1         = 'ICON_OKAY'
          text_button_2         = 'Hayır'
          icon_button_2         = 'ICON_CANCEL'
          default_button        = '2'
          display_cancel_button = 'X'
        IMPORTING
          answer                = lv_answer.

      IF lv_answer = '1'.
        PERFORM save_data.
      ELSE.
        MESSAGE 'işlem iptal edildi ' TYPE 'S' DISPLAY LIKE 'E'.
      ENDIF.
      SET SCREEN 0100.



  ENDCASE.

ENDMODULE.
