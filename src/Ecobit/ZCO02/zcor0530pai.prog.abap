*&---------------------------------------------------------------------*
*& Include          ZCOR0530PAI
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  EXIT_0100  INPUT
*&---------------------------------------------------------------------*
MODULE EXIT_0100 INPUT.

  SAVE_OK = OK_CODE. CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'CANC'.
      LEAVE TO SCREEN 0.
    WHEN 'EXIT'.
      LEAVE PROGRAM.
  ENDCASE.


ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  SAVE_OK = OK_CODE. CLEAR OK_CODE.

  CASE SAVE_OK.
    WHEN 'SAVE'.
      PERFORM SAVE_DATA.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      OK_CODE = SAVE_OK.
  ENDCASE.

ENDMODULE.
