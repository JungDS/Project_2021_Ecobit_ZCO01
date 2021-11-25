FUNCTION ZCO_MM_COSTACTPLN_POSTPRIMCOST.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IS_HEADER) TYPE  ZCOS0270
*"     VALUE(IS_VALUE) TYPE  ZCOS0271
*"  EXPORTING
*"     VALUE(E_RESULT) TYPE  BAPI_MTYPE
*"     VALUE(E_MSG) TYPE  BAPI_MSG
*"----------------------------------------------------------------------
  DEFINE _INIT_CHK.
    IF  E_RESULT IS INITIAL .
     IF &1 IS INITIAL .
       E_RESULT = 'E'.
       E_MSG    = &2 && | | && &3. "필드명 + 필수 입력 필드 입니다 .
       EXIT.
     ENDIF.
    ENDIF.
  END-OF-DEFINITION .

  DATA: LS_HEADERINFO     LIKE  BAPIPLNHDR.

  DATA: LT_INDEXSTRUCTURE LIKE BAPIACPSTRU OCCURS 0 WITH HEADER LINE,
        LT_COOBJECT       LIKE BAPIPCPOBJ  OCCURS 0 WITH HEADER LINE,
        LT_PERVALUE       LIKE BAPIPCPVAL  OCCURS 0 WITH HEADER LINE.

  DATA: LT_RETURN TYPE TABLE OF BAPIRET2 WITH HEADER LINE.

*-- 필수 체크
  _INIT_CHK: IS_HEADER-CO_AREA       TEXT-F01 TEXT-M01, "관리 회계영역
             IS_HEADER-FISC_YEAR     TEXT-F02 TEXT-M01, "회계연도
             IS_HEADER-PERIOD_FROM   TEXT-F03 TEXT-M01, "기간 시작
             IS_HEADER-PERIOD_TO     TEXT-F04 TEXT-M01, "기간 종료
             IS_HEADER-VERSION       TEXT-F05 TEXT-M01, "버전
             IS_HEADER-PLAN_CURRTYPE TEXT-F06 TEXT-M01, "통화
             IS_VALUE-WBS_ELEMENT    TEXT-F07 TEXT-M01, "WBS
             IS_VALUE-COST_ELEM      TEXT-F08 TEXT-M01, "원가요소
             IS_VALUE-TRANS_CURR     TEXT-F09 TEXT-M01. "통화키

  "Planning ( CJR2 )
*-- Header Data
  LS_HEADERINFO-CO_AREA       = IS_HEADER-CO_AREA.        "관리 회계영역
  LS_HEADERINFO-FISC_YEAR     = IS_HEADER-FISC_YEAR.      "회계연도
  LS_HEADERINFO-PERIOD_FROM   = IS_HEADER-PERIOD_FROM.    "기간 시작
  LS_HEADERINFO-PERIOD_TO     = IS_HEADER-PERIOD_TO.      "기간 종료
  LS_HEADERINFO-VERSION       = IS_HEADER-VERSION.        "버전
  LS_HEADERINFO-PLAN_CURRTYPE = IS_HEADER-PLAN_CURRTYPE.  "통화

*-- CO-계획: 액티비티투입 & 주요지표 계획 BAPIs
  LT_INDEXSTRUCTURE-OBJECT_INDEX = 1.
  LT_INDEXSTRUCTURE-VALUE_INDEX  = 1.
  APPEND LT_INDEXSTRUCTURE.

*-- CO 계획: 1차 원가 BAPI에 대한 오브젝트
  LT_COOBJECT-OBJECT_INDEX = 1.
  LT_COOBJECT-WBS_ELEMENT  = IS_VALUE-WBS_ELEMENT.        " WBS
  APPEND LT_COOBJECT.

*-- CO 계획: 1차 원가 BAPI에 대한 값
  LT_PERVALUE-VALUE_INDEX  = 1.
  LT_PERVALUE-COST_ELEM     = IS_VALUE-COST_ELEM.         "원가요소
  LT_PERVALUE-TRANS_CURR    = IS_VALUE-TRANS_CURR.        "통화키
  LT_PERVALUE-FIX_VAL_PER01 = IS_VALUE-FIX_VAL_PER01.
  LT_PERVALUE-FIX_VAL_PER02 = IS_VALUE-FIX_VAL_PER02.
  LT_PERVALUE-FIX_VAL_PER03 = IS_VALUE-FIX_VAL_PER03.
  LT_PERVALUE-FIX_VAL_PER04 = IS_VALUE-FIX_VAL_PER04.
  LT_PERVALUE-FIX_VAL_PER05 = IS_VALUE-FIX_VAL_PER05.
  LT_PERVALUE-FIX_VAL_PER06 = IS_VALUE-FIX_VAL_PER06.
  LT_PERVALUE-FIX_VAL_PER07 = IS_VALUE-FIX_VAL_PER07.
  LT_PERVALUE-FIX_VAL_PER08 = IS_VALUE-FIX_VAL_PER08.
  LT_PERVALUE-FIX_VAL_PER09 = IS_VALUE-FIX_VAL_PER09.
  LT_PERVALUE-FIX_VAL_PER10 = IS_VALUE-FIX_VAL_PER10.
  LT_PERVALUE-FIX_VAL_PER11 = IS_VALUE-FIX_VAL_PER11.
  LT_PERVALUE-FIX_VAL_PER12 = IS_VALUE-FIX_VAL_PER12.
  APPEND LT_PERVALUE.

  CALL FUNCTION 'BAPI_COSTACTPLN_POSTPRIMCOST'
    EXPORTING
      HEADERINFO     = LS_HEADERINFO
    TABLES
      INDEXSTRUCTURE = LT_INDEXSTRUCTURE
      COOBJECT       = LT_COOBJECT
      PERVALUE       = LT_PERVALUE
      RETURN         = LT_RETURN.

  READ TABLE LT_RETURN WITH KEY TYPE = 'E'.
  IF SY-SUBRC EQ 0 .

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    E_RESULT = LT_RETURN-TYPE.

    CALL FUNCTION 'MESSAGE_TEXT_BUILD'
      EXPORTING
        MSGID               = LT_RETURN-ID
        MSGNR               = LT_RETURN-NUMBER
        MSGV1               = LT_RETURN-MESSAGE_V1
        MSGV2               = LT_RETURN-MESSAGE_V2
        MSGV3               = LT_RETURN-MESSAGE_V3
        MSGV4               = LT_RETURN-MESSAGE_V4
      IMPORTING
        MESSAGE_TEXT_OUTPUT = E_MSG.

  ELSE.

    E_RESULT = 'S'.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

  ENDIF.
ENDFUNCTION.