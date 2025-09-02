*----------------------------------------------------------------------*
***INCLUDE Z_CS03_MOODES.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.
ENDMODULE.



*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
  CASE sy-ucomm.
    WHEN '&BCK' OR '&EXT'.
      PERFORM clear_all_globals.
      SET SCREEN 0.
    WHEN '&OK'.
      PERFORM check_header .
      PERFORM  get_data.
      IF sy-subrc = 0.
        CALL SCREEN 0200.
      ELSE.
        MESSAGE 'BOM kaydı oluşturulamadı!' TYPE 'E'.
      ENDIF.


  ENDCASE.

ENDMODULE.






*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS '0100'.
* SET TITLEBAR 'xxx'.


  DATA lv_plan_text TYPE ddtext.
  DATA lv_stlal_text TYPE ddtext.
  DATA lv_matnr_text TYPE string.

  " Domain değerlerini FM tipine uygun geçici değişken ile hazırla
  DATA lv_plant_dd07l TYPE dd07l-domvalue_l.
  DATA lv_stlal_dd07l TYPE dd07l-domvalue_l.

  lv_plant_dd07l = gv_plant.
  lv_stlal_dd07l = gv_stlal.

  " Domain açıklamaları
  PERFORM get_value_range_text
    USING lv_plant_dd07l
          'Z_DM_WERKS'
    CHANGING lv_plan_text.

  PERFORM get_value_range_text
    USING lv_stlal_dd07l
          'ZDM_ALTNR'
    CHANGING lv_stlal_text.

  " MATNR açıklaması (tablo lookup)
  SELECT SINGLE maktx
    INTO lv_matnr_text
    FROM zzp_malzeme
    WHERE matnr = gv_matnr.

  IF sy-subrc <> 0.
    lv_matnr_text = 'Bulunamadı'.
  ENDIF.

  " Ekran alanlarına ata
  gv_plan_text  = lv_plan_text.
  gv_stlal_text = lv_stlal_text.
  gv_matnr_text = lv_matnr_text.

  IF g_container IS INITIAL .
    PERFORM create_alv.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0200  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.
  CASE sy-ucomm.
    WHEN '&BCK' OR '&EXT'.
      SET SCREEN 0.
  ENDCASE.
ENDMODULE.
