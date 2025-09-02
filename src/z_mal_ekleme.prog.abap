*&---------------------------------------------------------------------*
*& Report Z_MAL_EKLEME
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_mal_ekleme.

DATA : gv_matnr TYPE matnr,
       gv_matkl TYPE zmatkl,
       GV_maktx TYPE maktx,
       gv_meıns TYPE meıns,
       gv_brgew TYPE brgew,
       gv_ntgew TYPE ntgew,
       gv_geweı TYPE geweı,
       gv_volum TYPE volum,
       gv_voleh TYPE voleh,
       gv_laeda TYPE datum,
       gv_ersda TYPE ersda,
       gv_labst TYPE zde_labst.


START-OF-SELECTION.
  CALL SCREEN 0100.

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
    WHEN  '&BCK' OR '&EXT'.
      LEAVE TO SCREEN 0.
    WHEN '&INSRT' .
      PERFORM insert_data.
    WHEN OTHERS.
  ENDCASE.

ENDMODULE.



*&---------------------------------------------------------------------*
*& Form INSERT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM insert_data .


  DATA: wa_malzeme TYPE zzp_malzeme.

  IF gv_matnr IS INITIAL.
    MESSAGE 'Malzeme numarası boş olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF gv_matkl IS INITIAL.
    MESSAGE 'Malzeme grubu boş olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF gv_meins IS INITIAL.
    MESSAGE 'Temel ölçü birimi boş olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF gv_brgew IS INITIAL.
    MESSAGE 'Brüt ağırlık boş olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF gv_ntgew IS INITIAL.
    MESSAGE 'Net ağırlık boş olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF gv_labst IS INITIAL.
    MESSAGE 'Stok miktarı boş olamaz!' TYPE 'S' DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.


  IF strlen( gv_matnr ) > 18.
    MESSAGE 'Malzeme numarası maksimum 18 karakter olmalı!' TYPE 'E'. EXIT. ENDIF.

  IF strlen( gv_matkl ) > 9.
    MESSAGE 'Malzeme grubu maksimum 9 karakter olmalı!' TYPE 'E'. EXIT. ENDIF.


  IF gv_brgew <= 0 OR gv_ntgew <= 0.
    MESSAGE 'Ağırlık değerleri pozitif sayı olmalı!' TYPE 'E'. EXIT. ENDIF.

  IF gv_volum < 0.
    MESSAGE 'Hacim değerleri negatif olamaz!' TYPE 'E'. EXIT. ENDIF.


  IF gv_laeda IS NOT INITIAL AND  ( gv_laeda < '19000101' OR gv_laeda > sy-datum  ) .
    MESSAGE 'Tarih geçersiz!' TYPE 'E'. EXIT. ENDIF.



  wa_malzeme-matnr  = gv_matnr.
  wa_malzeme-matkl  = gv_matkl.
  wa_malzeme-meins  = gv_meins.
  wa_malzeme-brgew  = gv_brgew.
  wa_malzeme-mtgew  = gv_ntgew.
  wa_malzeme-gewei  = gv_gewei.
  wa_malzeme-volum  = gv_volum.
  wa_malzeme-voleh  = gv_voleh.
  wa_malzeme-laeda  = sy-datum.
  wa_malzeme-ersda  = sy-datum.
  wa_malzeme-labst  = gv_labst.
  wa_malzeme-maktx  = gv_maktx.


  INSERT INTO zzp_malzeme VALUES wa_malzeme.

  IF sy-subrc = 0.
    MESSAGE 'Kayıt başarıyla eklendi.' TYPE 'S'.
  ELSE.
    MESSAGE 'Kayıt eklenemedi!' TYPE 'E'.
  ENDIF.

ENDFORM.
