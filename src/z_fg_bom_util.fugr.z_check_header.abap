FUNCTION Z_CHECK_HEADER.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IV_MATNR) TYPE  MATNR
*"     REFERENCE(IV_PLANT) TYPE  ZDE_WRAKAN
*"     REFERENCE(IV_STLAN) TYPE  ZDE_STLAN
*"     REFERENCE(IV_STLAL) TYPE  ZDE_STLAT OPTIONAL
*"     REFERENCE(IV_DATUV) TYPE  DATUV
*"  EXPORTING
*"     REFERENCE(EV_RC) TYPE  I
*"     REFERENCE(EV_MESSAGE) TYPE  STRING
*"----------------------------------------------------------------------

  DATA lv_num    TYPE i.
  DATA lv_len    TYPE i.
  CLEAR : ev_message, ev_rc.
  ev_rc = 0.
  ev_message = ''.

  "--------------------------------------------------
  " 1. Material (MATNR) Check
  "--------------------------------------------------
  IF iv_matnr IS INITIAL.
     ev_rc = 4.
    ev_message = 'Material cannot be empty'.
    RETURN.
  ELSE.
    " Length check (classical ABAP)
    lv_len = STRLEN( iv_matnr ).
    IF lv_len > 18.
       ev_rc = 4.
      ev_message = 'Material too long'.
      RETURN.
    ENDIF.

    SELECT SINGLE matnr FROM zzp_malzeme INTO @DATA(lv_matnr)
      WHERE matnr = @iv_matnr.
    IF sy-subrc <> 0.
       ev_rc = 4.
      ev_message = 'Material not found in master data'.
      RETURN.
    ENDIF.
  ENDIF.

  "--------------------------------------------------
  " 2. Plant (WERKS) Check
  "--------------------------------------------------
  IF iv_plant IS INITIAL.
     ev_rc = 4.
    ev_message = 'Plant cannot be empty'.
    RETURN.
  ELSE.
    TRY.
        lv_num = iv_plant + 0.
      CATCH cx_sy_conversion_no_number.
         ev_rc = 4.
        ev_message = 'Plant must be numeric'.
        RETURN.
    ENDTRY.

    CASE iv_plant.
      WHEN '1000' OR '2000' OR '3000' OR '4000'.
        " valid
      WHEN OTHERS.
         ev_rc = 4.
        ev_message = 'Invalid Plant'.
        RETURN.
    ENDCASE.
  ENDIF.

  "--------------------------------------------------
  " 3. BOM Usage (STLAN) Check
  "--------------------------------------------------
  IF iv_stlan IS INITIAL.
     ev_rc = 4.
    ev_message = 'BOM Usage cannot be empty'.
    RETURN.
  ELSE.
    CASE iv_stlan.
      WHEN '1' OR '2' OR '3' OR '4'.
        " valid
      WHEN OTHERS.
         ev_rc = 4.
        ev_message = 'Invalid BOM Usage'.
        RETURN.
    ENDCASE.
  ENDIF.

  "--------------------------------------------------
  " 4. Alternative BOM (STLAL) Check
  "--------------------------------------------------
  IF iv_stlal IS NOT INITIAL.
    lv_len = STRLEN( iv_stlal ).
    IF lv_len > 2.
       ev_rc = 4.
      ev_message = 'Alternative BOM max 2 characters'.
      RETURN.
    ENDIF.
  ENDIF.

  "--------------------------------------------------
  " 5. Valid-From Date (DATUV) Check
  "--------------------------------------------------
  IF iv_datuv IS INITIAL.
     ev_rc = 4.
    ev_message = 'Valid-From Date cannot be empty'.
    RETURN.
  ELSEIF iv_datuv < sy-datum.
     ev_rc = 4.
    ev_message = 'Date cannot be in the past'.
    RETURN.
  ENDIF.

ENDFUNCTION.
