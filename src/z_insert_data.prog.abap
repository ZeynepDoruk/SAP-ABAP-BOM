*&---------------------------------------------------------------------*
*& Report Z_INSERT_DATA
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_insert_data.
*
*DATA: lv_t023   TYPE zzp_t023,
*      lv_result TYPE sy-subrc.
*
*lv_t023-matkl = 'SPORTS'.
*lv_t023-wgbez = 'Spor malzemeleri'.
*
*INSERT zzp_t023 FROM lv_t023.
*lv_result = sy-subrc.
*
*IF lv_result = 0.
*  WRITE: / 'Kayıt başarıyla eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / 'Kayıt zaten mevcut, eklenmedi.'.
*ELSE.
*  WRITE: / 'Kayıt eklenirken hata oluştu. SY-SUBRC =', lv_result.
*ENDIF.
*** 2. Kayıt - ELEKTRON
*lv_t023-matkl = 'KIRTASIYE'.
*lv_t023-wgbez = 'kırtasiye malzemeleri'.
*
*INSERT zzp_t023 FROM lv_t023.
*lv_result = sy-subrc.
*
*IF lv_result = 0.
*  WRITE: / 'ELEKTRON kaydı başarıyla eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / 'ELEKTRON kaydı zaten mevcut.'.
*ELSE.
*  WRITE: / 'ELEKTRON eklenirken hata oluştu. SY-SUBRC =', lv_result.
*ENDIF.
*
** 3. Kayıt - GIDA
*lv_t023-matkl = 'GIDA'.
*lv_t023-wgbez = 'Gıda ve İçecekler'.
*
*INSERT zzp_t023 FROM lv_t023.
*lv_result = sy-subrc.
*
*IF lv_result = 0.
*  WRITE: / 'GIDA kaydı başarıyla eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / 'GIDA kaydı zaten mevcut.'.
*ELSE.
*  WRITE: / 'GIDA eklenirken hata oluştu. SY-SUBRC =', lv_result.
*ENDIF.
*
*DATA: lv_malzeme TYPE zzp_malzeme,
*      lv_result  TYPE sy-subrc.
*
*" 1. Kayıt
*
*lv_malzeme-matnr = 'MAT-000000001'.
*lv_malzeme-matkl = 'ELEKTRON'.
*lv_malzeme-meins = 'PC'.
*lv_malzeme-brgew = '1.25'.
*lv_malzeme-mtgew = '1.25'.
*lv_malzeme-gewei = 'KG'.
*lv_malzeme-volum = '0'.        " Örnek veri yok, 0 veya boş bırakılabilir
*lv_malzeme-voleh = ''.         " Hacim birimi boş
*lv_malzeme-laeda = '12.07.2025'. " Tarih yok, tarih alanlarında '00000000' yazılabilir
*lv_malzeme-ersda = '01.02.2025'. " Oluşturma tarihi yok
*lv_malzeme-labst = 50.
*
*
*
*
*
*insert zzp_malzeme FROM lv_malzeme.
*lv_result = sy-subrc.
*IF lv_result = 0.
*  WRITE: / '1. Kayıt eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / '1. Kayıt zaten var.'.
*ELSE.
*  WRITE: / '1. Kayıt eklenemedi. SY-SUBRC:', lv_result.
*ENDIF.

*" 2. Kayıt
*
*lv_malzeme-matnr = 'MAT-000000002'.
*lv_malzeme-matkl = 'MOBILYA'.
*lv_malzeme-meins = 'ST'.
*lv_malzeme-brgew = '10.00'.
*lv_malzeme-mtgew = '10.00'.
*lv_malzeme-gewei = 'KG'.
*lv_malzeme-volum = '0'.
*lv_malzeme-voleh = ''.
*lv_malzeme-laeda = '00000000'.
*lv_malzeme-ersda = '00000000'.
*lv_malzeme-labst = 20.
*
*INSERT zzp_malzeme FROM lv_malzeme.
*lv_result = sy-subrc.
*IF lv_result = 0.
*  WRITE: / '2. Kayıt eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / '2. Kayıt zaten var.'.
*ELSE.
*  WRITE: / '2. Kayıt eklenemedi. SY-SUBRC:', lv_result.
*ENDIF.
*
*" 3. Kayıt
*
*lv_malzeme-matnr = 'MAT-000000003'.
*lv_malzeme-matkl = 'TEKSTIL'.
*lv_malzeme-meins = 'M'.
*lv_malzeme-brgew = '0.50'.
*lv_malzeme-mtgew = '0.50'.
*lv_malzeme-gewei = 'KG'.
*lv_malzeme-volum = '0'.
*lv_malzeme-voleh = ''.
*lv_malzeme-laeda = '00000000'.
*lv_malzeme-ersda = '00000000'.
*lv_malzeme-labst = 150.
*
*INSERT zzp_malzeme FROM lv_malzeme.
*lv_result = sy-subrc.
*IF lv_result = 0.
*  WRITE: / '3. Kayıt eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / '3. Kayıt zaten var.'.
*ELSE.
*  WRITE: / '3. Kayıt eklenemedi. SY-SUBRC:', lv_result.
*ENDIF.
*
*" 4. Kayıt
*
*lv_malzeme-matnr = 'MAT-000000004'.
*lv_malzeme-matkl = 'GIDA'.
*lv_malzeme-meins = 'KG'.
*lv_malzeme-brgew = '5.00'.
*lv_malzeme-mtgew = '5.00'.
*lv_malzeme-gewei = 'KG'.
*lv_malzeme-volum = '0'.
*lv_malzeme-voleh = ''.
*lv_malzeme-laeda = '00000000'.
*lv_malzeme-ersda = '00000000'.
*lv_malzeme-labst = 200.
*
*INSERT zzp_malzeme FROM lv_malzeme.
*lv_result = sy-subrc.
*IF lv_result = 0.
*  WRITE: / '4. Kayıt eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / '4. Kayıt zaten var.'.
*ELSE.
*  WRITE: / '4. Kayıt eklenemedi. SY-SUBRC:', lv_result.
*ENDIF.
*
*" 5. Kayıt
*
*lv_malzeme-matnr = 'MAT-000000005'.
*lv_malzeme-matkl = 'KIRTASIYE'.
*lv_malzeme-meins = 'ST'.
*lv_malzeme-brgew = '0.10'.
*lv_malzeme-mtgew = '0.10'.
*lv_malzeme-gewei = 'KG'.
*lv_malzeme-volum = '0'.
*lv_malzeme-voleh = ''.
*lv_malzeme-laeda = '00000000'.
*lv_malzeme-ersda = '00000000'.
*lv_malzeme-labst = 500.
*
*INSERT zzp_malzeme FROM lv_malzeme.
*lv_result = sy-subrc.
*IF lv_result = 0.
*  WRITE: / '5. Kayıt eklendi.'.
*ELSEIF lv_result = 4.
*  WRITE: / '5. Kayıt zaten var.'.
*ELSE.
*  WRITE: / '5. Kayıt eklenemedi. SY-SUBRC:', lv_result.
*ENDIF.

*DATA: lt_units TYPE TABLE OF t006,
*      ls_unit  TYPE t006.
*SELECT * FROM t006 INTO TABLE lt_units ORDER BY msehi.
*LOOP AT lt_units INTO ls_unit.
*  WRITE: / 'aaaaa', ls_unit-famunit .
*ENDLOOP.


*

*INSERT INTO zzp_malzeme VALUES ( '100', 'MAT000000000000001', 'ELEKTRONIK', 'ST', 15, 10, 'KG', 2, 'M3', '20250801', '20250801', 100).
*INSERT INTO zzp_malzeme VALUES ('100', 'MAT000000000000002', 'TEKSTIL',    'AD',  8,  7, 'KG', 1, 'LTR', '20250802', '20250802', 55).
*INSERT INTO zzp_malzeme VALUES ('100', 'MAT000000000000003', 'KIRTASIYE',  'AD',  1,  1, 'KG', 0, 'M3', '20250803', '20250803', 200).
*INSERT INTO zzp_malzeme VALUES ('100', 'MAT000000000000004', 'GIDA',       'KG', 20, 19, 'KG', 3, 'LTR', '20250804', '20250804', 75).
*INSERT INTO zzp_malzeme VALUES ('100', 'MAT000000000000005', 'PLASTIK',    'LT',  2,  2, 'KG', 0, 'LTR', '20250805', '20250805', 320).


*DATA: lt_malzeme TYPE TABLE OF zzp_malzeme,
*      ls_malzeme TYPE zzp_malzeme.
*
*" Tüm kayıtları çek
*SELECT *
*  FROM zzp_malzeme
*  INTO TABLE lt_malzeme.
*
*" Kontrol için yazdır
*LOOP AT lt_malzeme INTO ls_malzeme.
*  WRITE: / ls_malzeme-matnr ,ls_malzeme-matkl.
*ENDLOOP.


DATA: lt_malzeme TYPE TABLE OF zzp_malzeme,
      ls_malzeme TYPE zzp_malzeme,
      lv_maktx   TYPE char40.

" Tüm kayıtları çek
SELECT *
  FROM zzp_malzeme
  INTO TABLE lt_malzeme.

LOOP AT lt_malzeme INTO ls_malzeme.

  CASE ls_malzeme-matnr.
    WHEN 'MAT-0000000006'. lv_maktx = 'Bisiklet'.
    WHEN 'MAT-0000000007'. lv_maktx = 'Tekerlek'.
    WHEN 'MAT-0000000008'. lv_maktx = 'Kadro'.
    WHEN 'MAT-0000000009'. lv_maktx = 'Zincir'.
    WHEN 'MAT-0000000010'. lv_maktx = 'Sele'.
    WHEN 'MAT-000000001'.  lv_maktx = 'Elektron Cihaz'.
    WHEN 'MAT-000000002'.  lv_maktx = 'Sandalye'.
    WHEN 'MAT-000000003'.  lv_maktx = 'Tişört'.
    WHEN 'MAT-000000004'.  lv_maktx = 'Un'.
    WHEN 'MAT-000000005'.  lv_maktx = 'Kalem'.
    WHEN OTHERS.           lv_maktx = 'Diğer Malzeme'.
  ENDCASE.

  " Update ile kaydı güncelle
  UPDATE zzp_malzeme
    SET maktx = lv_maktx
    WHERE matnr = ls_malzeme-matnr.

ENDLOOP.

COMMIT WORK.

WRITE: / 'MAKTX alanları güncellendi (malzeme isimleri olarak).'.
