*&--------------------------------------------------------------------&*
*& PROGRAM ID  : ZCOR0420N                                            &*
*& Title       : [CO] 임시전표 불일치 확인/보정                       &*
*& Created By  : BSGSM_CO(JCHS)                                       &*
*& Created On  : 2020.03.02                                           &*
*& Description : [CO] 임시전표 불일치 확인/보정                       &*
*----------------------------------------------------------------------*
* MODIFICATION LOG
*----------------------------------------------------------------------*
* Tag  Date.       Author.         Description.
*----------------------------------------------------------------------*
* N    2020.03.02  BSGSM_CO(JCHS)  INITIAL RELEASE
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
* INCLUDE
*----------------------------------------------------------------------*
INCLUDE ZCOR0420NT01.    "선언
INCLUDE ZCOR0420NALV.    "ALV
INCLUDE ZCOR0420NSCR.    "PBO/PAI
INCLUDE ZCOR0420NF01.    "FORM

*----------------------------------------------------------------------*
INITIALIZATION.
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
AT SELECTION-SCREEN.
*---------------------------------------------------------------------*

*----------------------------------------------------------------------*
START-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM SELECT_DATA.

*----------------------------------------------------------------------*
END-OF-SELECTION.
*----------------------------------------------------------------------*
  PERFORM CALL_SCREEN.