*&---------------------------------------------------------------------*
*& Include          ZCOR0050F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECTED_DATA_RTN
*&---------------------------------------------------------------------*
FORM selected_data_rtn .

  PERFORM selected_main_data.

ENDFORM.                    " SELECTED_DATA_RTN
*&---------------------------------------------------------------------*
*&      Form  SELECTED_MAIN_DATA
*&---------------------------------------------------------------------*
FORM selected_main_data.

  CLEAR : gt_display , gt_display[].
  CLEAR:  gt_display_log, gt_display_log[].

  SELECT a~* , b~ktext, c~post1 ,
     '@5B@' AS icon  "ADD BSGSM_FCM
    INTO CORRESPONDING FIELDS OF TABLE @gt_display
    FROM zcot0030 AS a
    LEFT JOIN cskt AS b
      ON a~kostl = b~kostl
     AND b~spras = @sy-langu
     AND b~datbi = '99991231'
    LEFT JOIN prps AS c
      ON a~posid = c~posid
   WHERE a~kokrs = @pa_kokrs
     AND a~gjahr = @pa_gjahr.


* ADD  BSGSM_FCM

  LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<fs>).


    CLEAR gt_style[].
    _style_disabled : 'KOSTL'.
    _style_disabled : 'POSID'.
    _style_disabled : 'BEXCL'.


    <fs>-style[] = gt_style[].

  ENDLOOP.

* END BY BSGSM_FCM

  DATA(lv_lines) = lines( gt_display ).

  MESSAGE s039 WITH lv_lines.

  gt_display_log[] = gt_display[].

ENDFORM.                    " SELECTED_MAIN_DATA
*&---------------------------------------------------------------------*
*&      Form  EVENT_TOOLBAR
*&---------------------------------------------------------------------*
FORM event_toolbar
       USING pr_object     TYPE REF TO cl_alv_event_toolbar_set
             pv_interactive TYPE char01
             pr_sender     TYPE REF TO cl_gui_alv_grid.

  CASE pr_sender.

    WHEN gr_grid1.

*      "ADD_BUTTON : OBJECT, BTYPE, FUNC, ICON, INFO, TEXT, DISABLE
*      PERFORM ADD_BUTTON
*        USING: PR_OBJECT '3' SPACE SPACE SPACE SPACE SPACE, "분리자
*
*               PR_OBJECT '0' '&APD' ICON_CREATE TEXT-BT1
*                 TEXT-BT1 SPACE,
*
*               PR_OBJECT '0' '&INS' ICON_INSERT_ROW TEXT-BT2
*                 TEXT-BT2 SPACE,
*
*               PR_OBJECT '0' '&DEL' ICON_DELETE_ROW TEXT-BT3
*                 TEXT-BT3 SPACE.

    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    " EVENT_TOOLBAR
*&---------------------------------------------------------------------*
*&      Form ADD_BUTTON
*&---------------------------------------------------------------------*
FORM add_button USING pr_object TYPE REF TO cl_alv_event_toolbar_set
                    pv_btype
                    pv_func
                    pv_icon
                    pv_info
                    pv_text
                    pv_disa.

  DATA: ls_button TYPE stb_button,
        ls_btnmnu TYPE stb_btnmnu,

        lt_button TYPE ttb_button,
        lt_btnmnu TYPE ttb_btnmnu.

  CLEAR ls_button.
  ls_button-butn_type = pv_btype.
  ls_button-function  = pv_func.
  ls_button-icon      = pv_icon.
  ls_button-quickinfo = pv_info.

  ls_button-text      = pv_text.
  ls_button-disabled  = pv_disa.

  APPEND ls_button TO pr_object->mt_toolbar.

ENDFORM.                   " ADD_BUTTON
*&---------------------------------------------------------------------*
*&      Form  EVENT_USER_COMMAND
*&---------------------------------------------------------------------*
FORM event_user_command  USING pv_ucomm   TYPE sy-ucomm
                               pr_sender TYPE REF TO cl_gui_alv_grid.

  DATA: lv_row TYPE i,
        lv_col TYPE i.

  CLEAR: gt_rows, gt_rows[].

  "선택 ROW가져오기
  CALL METHOD pr_sender->get_selected_rows
    IMPORTING
      et_index_rows = gt_rows[].


  "GRID에 따라 처리.
  CASE pr_sender.
    WHEN gr_grid1.
      CASE pv_ucomm.
*        WHEN '&APD'.   "-- 행 추가

*          " 마지막행에 ROW 추가하기.
*          "   -선언한 STRUCTURE로 초기값을 넣어 추가할 수도 있다.
*          CLEAR: GS_DISPLAY, GT_STYLE[], GS_STYLE.
*          GS_DISPLAY-UPDATE_FLAG = 'I'. "삽입.
*
*          " TEXT 필드 편집금지
*          _STYLE_DISABLED: 'CITYFROM', 'CITYTO'.
*          GS_DISPLAY-STYLE[] = GT_STYLE[].
*          APPEND GS_DISPLAY TO GT_DISPLAY.
*
*
*          " REFRESH
*          PERFORM REFRESH_GRID_0100.
*
*          "-- APPEND를 하면 제일 아래로 행이 추가된다.
*          "   CURSOR을 제일 밑으로 자동으로 이동.
*          "   * SORT가 되어 있는 곳에서는 주석으로 막아야 함.
*          SY-TFILL = LINES( GT_DISPLAY ).
*          PERFORM SET_GRID_CURSOR
*            USING PR_SENDER SY-TFILL SPACE.
*
*        WHEN '&INS'.   "-- 행 삽입
*          "밑에서 부터 ROW를 추가해야 함.
*          IF GT_ROWS[] IS NOT INITIAL.
*            SORT GT_ROWS BY INDEX DESCENDING.
*
*            CLEAR: GS_DISPLAY, GT_STYLE[], GS_STYLE.
*            GS_DISPLAY-UPDATE_FLAG = 'I'. "삽입.
*            LOOP AT GT_ROWS INTO GS_ROWS WHERE ROWTYPE IS INITIAL.
*              " TEXT 필드 편집금지
*              _STYLE_DISABLED: 'CITYFROM', 'CITYTO'.
*              GS_DISPLAY-STYLE[] = GT_STYLE[].
*
*              INSERT GS_DISPLAY INTO GT_DISPLAY INDEX GS_ROWS-INDEX.
*            ENDLOOP.
*
*
*            " REFRESH
*            PERFORM REFRESH_GRID_0100.
*
*            " 제일 마지막 ROW 바로 위 추가된 행에 커서 위치.
*            "   * SORT가 되어 있는 곳에서는 주석으로 막아야 함.
*            READ TABLE GT_ROWS INTO GS_ROWS INDEX 1.
*            SY-TFILL = GS_ROWS-INDEX + LINES( GT_ROWS ) - 1.
*            PERFORM SET_GRID_CURSOR
*              USING PR_SENDER SY-TFILL SPACE.
*
*          ELSE.
*            CLEAR: LV_ROW, LV_COL.
*
*            "선택된 ROW가 없으면 CURSOR의 위치를 기준으로 행추가
*            PERFORM GET_GRID_CURSOR USING PR_SENDER
*                                 CHANGING LV_ROW
*                                          LV_COL.
*
*            CLEAR: GS_DISPLAY, GT_STYLE[], GS_STYLE.
*            GS_DISPLAY-UPDATE_FLAG = 'I'. "삽입.
*
*            " TEXT 필드 편집금지
*            _STYLE_DISABLED: 'CITYFROM', 'CITYTO'.
*            GS_DISPLAY-STYLE[] = GT_STYLE[].
*
*            IF LINES( GT_DISPLAY[] ) IS NOT INITIAL.
*              INSERT GS_DISPLAY INTO GT_DISPLAY INDEX LV_ROW.
*            ENDIF.
*
*
*            " REFRESH
*            PERFORM REFRESH_GRID_0100.
*
*            "추가된 행에 커서 위치.
*            "   * SORT가 되어 있는 곳에서는 주석으로 막아야 함.
*            PERFORM SET_GRID_CURSOR
*              USING PR_SENDER LV_ROW SPACE.
*          ENDIF.
*
*        WHEN '&DEL'.   "-- 행 삭제
*
*          IF GT_ROWS[] IS INITIAL.
*            MESSAGE S021 DISPLAY LIKE 'E'.
*            RETURN.
*          ENDIF.
*
*          "밑에서 부터 지워야 한다.
*          SORT GT_ROWS BY INDEX DESCENDING.
*
*          LOOP AT GT_ROWS INTO GS_ROWS WHERE ROWTYPE IS INITIAL.
*
*            "삭제할 데이터를 ITAB에 따로 모은다.
*            "신규로 추가된 행은 제외.
*            READ TABLE GT_DISPLAY INTO GS_DISPLAY INDEX GS_ROWS-INDEX.
*            IF SY-SUBRC EQ 0 AND GS_DISPLAY-UPDATE_FLAG NE 'I'.
*              INSERT GS_DISPLAY INTO TABLE GT_DISPLAY_DEL.
*            ENDIF.
*
*            "실제 화면 DISPLAY에서 삭제.
*            DELETE GT_DISPLAY INDEX GS_ROWS-INDEX.
*          ENDLOOP.
*
*          PERFORM REFRESH_GRID_0100.

      ENDCASE.

    WHEN OTHERS.
  ENDCASE.


ENDFORM.                    " EVENT_USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
FORM event_data_changed
       USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
             pv_onf4          TYPE char01
             pv_onf4_before   TYPE char01
             pv_onf4_after    TYPE char01
             pv_ucomm         TYPE sy-ucomm
             pr_sender       TYPE REF TO cl_gui_alv_grid.

*--- Begin or Example
  DATA: ls_mod_cells TYPE lvc_s_modi,
        ls_ins_cells TYPE lvc_s_moce,
        ls_del_cells TYPE lvc_s_moce.

  DATA lv_post1 TYPE ps_post1.
  DATA lv_ktext TYPE ktext.
  DATA lv_posid TYPE ps_posid.
  DATA lv_kostl TYPE kostl.


  DATA lv_tabix TYPE sy-tabix.

  DEFINE _modify_cell.
    CALL METHOD pr_data_changed->modify_cell
      EXPORTING
        i_fieldname = &1
        i_row_id    = &2
        i_value     = &3.

  END-OF-DEFINITION.

  DEFINE _get_cell_value.
    CALL METHOD pr_data_changed->get_cell_value
      EXPORTING
        i_fieldname = &1
        i_row_id    = &2
      IMPORTING
        e_value     = &3.
  END-OF-DEFINITION.

  DEFINE _add_protocol.
    CALL METHOD pr_data_changed->add_protocol_entry
      EXPORTING
        i_fieldname = &1
        i_row_id    = &2
        i_msgid     = 'ZCO01'
        i_msgty     = &3
        i_msgno     = &4
        i_msgv1     = &5
        i_msgv2     = &6
        i_msgv3     = &7
        i_msgv4     = &8.
  END-OF-DEFINITION.

  DEFINE _modify_style.
    CALL METHOD pr_data_changed->modify_style
      EXPORTING
        i_fieldname = &1
        i_row_id    = &2
        i_style     = &3.
  END-OF-DEFINITION.
*--- End of Example

  CLEAR gv_exit.

  CASE pr_sender.

    WHEN gr_grid1.

      LOOP AT pr_data_changed->mt_inserted_rows INTO ls_ins_cells.

        _modify_cell:   'GJAHR' ls_ins_cells-row_id
                                pa_gjahr,
                        'KOKRS' ls_ins_cells-row_id
                                pa_kokrs,
                        'BEXCL' ls_ins_cells-row_id
                                abap_true.

      ENDLOOP.

      LOOP AT pr_data_changed->mt_mod_cells INTO ls_mod_cells.

        CASE ls_mod_cells-fieldname.

          WHEN 'KOSTL'.

            IF ls_mod_cells-value IS NOT INITIAL.

              lv_kostl = ls_mod_cells-value.

              _conversion_in lv_kostl.

              SELECT SINGLE b~ktext INTO @lv_ktext
                FROM csks AS a
                LEFT JOIN cskt AS b
                 ON a~kokrs = b~kokrs
                AND a~kostl = b~kostl
                AND a~datbi = b~datbi
                AND b~spras = @sy-langu
              WHERE a~kokrs = @pa_kokrs
                AND a~kostl = @lv_kostl
                AND a~datbi = '99991231'.

              IF sy-subrc <> 0.
                _add_protocol ls_mod_cells-fieldname ls_mod_cells-row_id
                              'E' 023 TEXT-c04 space space space.
                gv_exit = abap_true . EXIT.
              ENDIF.
            ENDIF.

            _modify_cell 'KTEXT' ls_mod_cells-row_id
                                 lv_ktext.

          WHEN 'POSID'.

            IF ls_mod_cells-value IS NOT INITIAL.

              CALL FUNCTION 'CONVERSION_EXIT_ABPSN_INPUT'
                EXPORTING
                  input  = ls_mod_cells-value
                IMPORTING
                  output = lv_posid.

              SELECT SINGLE post1 INTO @lv_post1
                FROM prps
               WHERE posid = @lv_posid.

              IF sy-subrc <> 0.
                _add_protocol ls_mod_cells-fieldname ls_mod_cells-row_id
                              'E' 023 TEXT-c06 space space space.
                gv_exit = abap_true . EXIT.
              ENDIF.
            ENDIF.

            _modify_cell 'POST1' ls_mod_cells-row_id
                                 lv_post1.
          WHEN OTHERS.

        ENDCASE.

      ENDLOOP.

  ENDCASE.

  CHECK gv_exit IS INITIAL.

  CALL METHOD pr_data_changed->display_protocol.

ENDFORM.
.                    " EVENT_DATA_CHANGED
*&---------------------------------------------------------------------*
*&      Form  EVENT_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
FORM event_data_changed_finished
       USING p_modified    TYPE char01
             pt_good_cells TYPE lvc_t_modi
             pr_sender    TYPE REF TO cl_gui_alv_grid.


* - Prefix 정의 - Form Parameter
*   1. PT_  : Internal Table or Ranges
*   2. PS_  : Structure
*   3. PV_  : Variables
*   4. PR_ : Reference Variables


ENDFORM.                    " EVENT_DATA_CHANGED_FINISHED
*&---------------------------------------------------------------------*
*&      Form  EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
FORM event_hotspot_click USING ps_row_id    TYPE lvc_s_row
                               ps_column_id TYPE lvc_s_col
                               ps_row_no    TYPE lvc_s_roid
                               pr_sender   TYPE REF TO cl_gui_alv_grid.


* - Prefix 정의 - Form Parameter
*   1. PT_  : Internal Table or Ranges
*   2. PS_  : Structure
*   3. PV_  : Variables
*   4. PR_ : Reference Variables

*
*  CASE PR_SENDER.
*    WHEN GR_GRID1.
*
*      CASE PS_COLUMN_ID-FIELDNAME.
*        WHEN 'CONNID'.
*
*      ENDCASE.
*
*    WHEN OTHERS.
*  ENDCASE.


ENDFORM.                    " EVENT_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*&      Form  EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM event_double_click  USING ps_row     TYPE lvc_s_row
                               ps_column  TYPE lvc_s_col
                               ps_row_no  TYPE lvc_s_roid
                               pr_sender TYPE REF TO cl_gui_alv_grid.


* - Prefix 정의 - Form Parameter
*   1. PT_  : Internal Table or Ranges
*   2. PS_  : Structure
*   3. PV_  : Variables
*   4. PR_ : Reference Variables


*  CASE PR_SENDER.
*    WHEN GR_GRID1.
*
*    WHEN OTHERS.
*  ENDCASE.

ENDFORM.                    " EVENT_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*&      Form  EVENT_HELP_ON_F4
*&---------------------------------------------------------------------*
FORM event_help_on_f4
       USING pv_fieldname   TYPE lvc_fname
             pv_fieldvalue  TYPE lvc_value
             ps_row_no      TYPE lvc_s_roid
             pr_event_data TYPE REF TO cl_alv_event_data
             pt_bad_cells   TYPE lvc_t_modi
             pv_display     TYPE char01
             pr_sender     TYPE REF TO cl_gui_alv_grid.


*  DATA :  IS_MODI TYPE LVC_S_MODI.
*  FIELD-SYMBOLS <F4TAB> TYPE LVC_T_MODI.
*  ASSIGN PR_EVENT_DATA->M_DATA->* TO <F4TAB>.
*
*  DATA LV_KAGRU TYPE KAGRU.

*  CASE PR_SENDER.
*
*    WHEN GR_GRID1.
*
*      CASE PV_FIELDNAME.
*
*        WHEN 'KAGRU'.
*
**          CALL FUNCTION 'K_GROUP_SELECT'
**            EXPORTING
**              FIELD_NAME    = 'KSTAR'
**              KOKRS         = PA_KOKRS
**              KTOPL         = GC_KTOPL
**            IMPORTING
**              SET_NAME      = LV_KAGRU
**            EXCEPTIONS
**              NO_SET_PICKED = 1
**              OTHERS        = 2.
**
**          IF SY-SUBRC <> 0.
**            EXIT.
**          ENDIF.
**
**          IF PV_DISPLAY IS INITIAL AND LV_KAGRU IS NOT INITIAL.
**            IS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
**            IS_MODI-FIELDNAME = PV_FIELDNAME.
**            IS_MODI-VALUE     = LV_KAGRU.
**            APPEND IS_MODI TO <F4TAB>.
**          ENDIF.
**
**          PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.
*
*      ENDCASE.
*
*    WHEN OTHERS.
*
*  ENDCASE.

ENDFORM.                    " EVENT_HELP_ON_F4
*&---------------------------------------------------------------------*
*&      Form  EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM event_top_of_page USING pr_dd         TYPE REF TO cl_dd_document
                             pv_table_index TYPE syindex
                             pr_sender     TYPE REF TO cl_gui_alv_grid.

* - Prefix 정의 - Form Parameter
*   1. PT_  : Internal Table or Ranges
*   2. PS_  : Structure
*   3. PV_  : Variables
*   4. PR_ : Reference Variables


*  CASE PR_SENDER.
*    WHEN GR_GRID1.
*    WHEN OTHERS.
*  ENDCASE.
ENDFORM.                    " EVENT_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  EVENT_END_OF_LIST
*&---------------------------------------------------------------------*
FORM event_end_of_list USING pr_dd     TYPE REF TO cl_dd_document
                             pr_sender TYPE REF TO cl_gui_alv_grid.

* - Prefix 정의 - Form Parameter
*   1. PT_  : Internal Table or Ranges
*   2. PS_  : Structure
*   3. PV_  : Variables
*   4. PR_ : Reference Variables


*  CASE PR_SENDER.
*    WHEN GR_GRID1.
*    WHEN OTHERS.
*  ENDCASE.


ENDFORM.                    " EVENT_END_OF_LIST
*&---------------------------------------------------------------------*
*&      Form  CREATE_INSTANCE_0100
*&---------------------------------------------------------------------*
FORM create_instance_0100 .
*-- 1. customer container

*  CREATE OBJECT GR_CON1
*    EXPORTING
*      CONTAINER_NAME = GV_CONTAINER. "USER가 정의한 CONTAINER
*
*  CREATE OBJECT GR_GRID1
*    EXPORTING
*      I_PARENT = GR_CON1.

*-- 2. full screen
  CREATE OBJECT gr_splitter1
    EXPORTING
      rows    = 2
      columns = 1
      parent  = cl_gui_splitter_container=>screen0.

*== get container instance
*-- 1. top of page
  gr_parent_html = gr_splitter1->get_container(
      row       = 1
      column    = 1 ).

  gr_data_container = gr_splitter1->get_container(
      row       = 2
      column    = 1 ).

  CALL METHOD gr_splitter1->set_row_height
    EXPORTING
      id     = 1
      height = 5.

  CALL METHOD gr_splitter1->set_row_height
    EXPORTING
      id     = 2
      height = 50.

  CREATE OBJECT gr_grid1
    EXPORTING
      i_parent = gr_data_container.

ENDFORM.                    " CREATE_INSTANCE_0100
*&---------------------------------------------------------------------*
*&      Form  INIT_LAYOUT_0100
*&---------------------------------------------------------------------*
FORM init_layout_0100.

  CLEAR gs_layout.

*  GS_LAYOUT-EDIT_MODE  = ABAP_TRUE.
  gs_layout-zebra      = abap_true.
*  GS_LAYOUT-CWIDTH_OPT = ABAP_TRUE.
  gs_layout-sel_mode   = 'D'. " "MODI BSGSM_FCM
*  GS_LAYOUT-SEL_MODE   = SPACE.     "B:단일,C:복수,D:셀,A:행/열
  gs_layout-box_fname  = space.
  gs_layout-no_rowmark = space.

  gs_layout-stylefname = 'STYLE'.
  gs_layout-ctab_fname = 'CELLCOLOR'.
*  GS_LAYOUT-INFO_FNAME = 'INFO'.

**  "alv title
**  GS_LAYOUT-GRID_TITLE = TEXT-GT1.

ENDFORM.                    " INIT_LAYOUT_0100
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_EXCLUDE_0100
*&---------------------------------------------------------------------*
FORM set_grid_exclude_0100 .

  DATA: ls_exclude LIKE LINE OF gt_exclude.
  REFRESH: gt_exclude.

  "-- DEFINE _SET_EX
  DEFINE _set_ex.
    CLEAR: ls_exclude.
    ls_exclude = &1.
    APPEND ls_exclude TO gt_exclude.
  END-OF-DEFINITION.

*
  _set_ex:
**   CL_GUI_ALV_GRID=>MC_FC_FIND,
*
*    "-- begin 기능버튼활성화시 제외
*    CL_GUI_ALV_GRID=>MC_FC_SORT_ASC,
*    CL_GUI_ALV_GRID=>MC_FC_SORT_DSC,
*    CL_GUI_ALV_GRID=>MC_MB_SUBTOT,
*    CL_GUI_ALV_GRID=>MC_MB_SUM,
*    "-- end
*
    cl_gui_alv_grid=>mc_fc_loc_copy_row,
    cl_gui_alv_grid=>mc_fc_loc_append_row,
    cl_gui_alv_grid=>mc_fc_loc_insert_row,
    cl_gui_alv_grid=>mc_fc_loc_move_row,
    cl_gui_alv_grid=>mc_fc_loc_delete_row,
*
*    "-- begin 기능버튼활성화
    cl_gui_alv_grid=>mc_fc_loc_copy,
    cl_gui_alv_grid=>mc_fc_loc_cut,
    cl_gui_alv_grid=>mc_fc_loc_paste,
    cl_gui_alv_grid=>mc_fc_loc_paste_new_row,
*    "-- end
*
    cl_gui_alv_grid=>mc_fc_loc_undo,
    cl_gui_alv_grid=>mc_fc_check,
**
***   CL_GUI_ALV_GRID=>MC_FC_DETAIL,
***   CL_GUI_ALV_GRID=>MC_FC_FILTER,
    cl_gui_alv_grid=>mc_fc_graph,
    cl_gui_alv_grid=>mc_fc_html,
    cl_gui_alv_grid=>mc_fc_info,
    cl_gui_alv_grid=>mc_fc_refresh,
*
***   CL_GUI_ALV_GRID=>MC_FC_VIEWS,
***   CL_GUI_ALV_GRID=>MC_FC_LOAD_VARIANT,
***   CL_GUI_ALV_GRID=>MC_FC_PRINT,
***   CL_GUI_ALV_GRID=>MC_MB_VARIANT,
***   CL_GUI_ALV_GRID=>MC_MB_EXPORT,
**
    cl_gui_alv_grid=>mc_fc_view_crystal,
    cl_gui_alv_grid=>mc_fc_view_excel,
    cl_gui_alv_grid=>mc_fc_view_grid,
    cl_gui_alv_grid=>mc_fc_view_lotus,
    cl_gui_alv_grid=>mc_fc_expcrdata,
    cl_gui_alv_grid=>mc_fc_expcrdesig,
    cl_gui_alv_grid=>mc_fc_expcrtempl,
    cl_gui_alv_grid=>mc_fc_call_abc,
    cl_gui_alv_grid=>mc_fc_call_crbatch.

ENDFORM. " SET_GRID_EXCLUDE_0100
*&---------------------------------------------------------------------*
*&      Form  ALV_SORT_0100
*&---------------------------------------------------------------------*
FORM alv_sort_0100 .

  CLEAR: gs_sort, gt_sort.
  REFRESH: gt_sort.

ENDFORM.                    " ALV_SORT_0100
*&---------------------------------------------------------------------*
*&      Form  APPEND_FIELDCAT_0100
*&---------------------------------------------------------------------*
FORM append_fieldcat_0100 .

  "-- field catalog data
  "   field catalog merge or set fieldcatalog를 사용할 수 있음.

  "{ FIELDCATLOG MERGE 사용
  PERFORM get_fieldcatlog_data.

  PERFORM modify_fieldcatlog_data.
  "}

  "{ SET FIELDCATLOG 사용
*  PERFORM SET_FIELDCATLOG_DATA.
  "}

ENDFORM.                    " APPEND_FIELDCAT_0100
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDCATLOG_DATA
*&---------------------------------------------------------------------*
FORM get_fieldcatlog_data .

  DATA: lt_fieldcat TYPE kkblo_t_fieldcat.

  CALL FUNCTION 'K_KKB_FIELDCAT_MERGE'
    EXPORTING
      i_callback_program     = sy-repid
      i_strucname            = 'ZCOS0030B' "ABAP DIC. 정의된 STRUCTURE
*     i_strucname            = 'ZCOS0030' "ABAP DIC. 정의된 STRUCTURE
      i_bypassing_buffer     = abap_true
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = lt_fieldcat[]
    EXCEPTIONS
      inconsistent_interface = 1
      OTHERS                 = 2.

  IF sy-subrc EQ 0.

    "-- Trasnfer LVC.
    CALL FUNCTION 'LVC_TRANSFER_FROM_KKBLO'
      EXPORTING
        it_fieldcat_kkblo = lt_fieldcat[]
      IMPORTING
        et_fieldcat_lvc   = gt_fieldcat[]
      EXCEPTIONS
        it_data_missing   = 1.
  ELSE.

    MESSAGE e020.

  ENDIF.

ENDFORM.                    " GET_FIELDCATLOG_DATA
*&---------------------------------------------------------------------*
*&      Form  MODIFY_FIELDCATLOG_DATA
*&---------------------------------------------------------------------*
FORM modify_fieldcatlog_data .

  DATA:  lv_text(50).

  LOOP AT gt_fieldcat INTO gs_fieldcat.

    CLEAR: lv_text.

    CASE gs_fieldcat-fieldname.

*ADD BSGSM_FCM  20210823
      WHEN 'ICON'.
        gs_fieldcat-just = 'C'.
        gs_fieldcat-outputlen = 4.
        gs_fieldcat-fix_column = 'X'.
        lv_text = TEXT-f01.
*END BY BSGSM_FCM...

      WHEN 'GJAHR'.
        lv_text = TEXT-c01.
        gs_fieldcat-outputlen = '8'.

      WHEN 'KOKRS'.
        lv_text = TEXT-c02.
        gs_fieldcat-outputlen = '8'.

      WHEN 'KOSTL'.
        lv_text = TEXT-c04.
        gs_fieldcat-outputlen = '10'.
        gs_fieldcat-edit = abap_true.
        gs_fieldcat-f4availabl = abap_true.

      WHEN 'KTEXT'.
        lv_text = TEXT-c05.
        gs_fieldcat-outputlen = '20'.

      WHEN 'POSID'.
        lv_text = TEXT-c06.
        gs_fieldcat-edit = abap_true.
        gs_fieldcat-outputlen = '15'.
        gs_fieldcat-f4availabl = abap_true.

      WHEN 'POST1'.
        lv_text = TEXT-c07.
        gs_fieldcat-outputlen = '30'.

      WHEN 'BEXCL'.
        lv_text = TEXT-c08.
        gs_fieldcat-edit   = abap_true.
        gs_fieldcat-checkbox  = abap_true.
        gs_fieldcat-outputlen = '12'.

      WHEN OTHERS.

    ENDCASE.

    "-- Common attribute
    IF lv_text IS NOT INITIAL.
      gs_fieldcat-coltext   = lv_text.
      gs_fieldcat-scrtext_l = lv_text.
      gs_fieldcat-scrtext_m = lv_text.
      gs_fieldcat-scrtext_s = lv_text.
    ENDIF.

    MODIFY gt_fieldcat FROM gs_fieldcat.
  ENDLOOP.

ENDFORM.                    " MODIFY_FIELDCATLOG_DATA
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCATLOG_DATA
*&---------------------------------------------------------------------*
FORM set_fieldcatlog_data.

  CLEAR gt_fieldcat[].

  PERFORM fill_field_category USING :
        'S' 'FIELDNAME'   'ICON',
        ' ' 'OUTPUTLEN'   '4',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     'ID',

        'S' 'FIELDNAME'   'CARRID',
        ' ' 'OUTPUTLEN'   '3',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '항공사 ID',

        'S' 'FIELDNAME'   'CONNID',
        ' ' 'OUTPUTLEN'   '4',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '운항연결 ID',

        'S' 'FIELDNAME'   'FLDATE',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '운항일',

        'S' 'FIELDNAME'   'PRICE',
        ' ' 'OUTPUTLEN'   '20',
        ' ' 'EDIT'        'X',
        ' ' 'CFIELDNAME'  'CURRENCY',
        'E' 'COLTEXT'     '가격',

        'S' 'FIELDNAME'   'CURRENCY',
        ' ' 'OUTPUTLEN'   '5',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '현지통화',

        'S' 'FIELDNAME'   'PLANETYPE',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '항공기',

        'S' 'FIELDNAME'   'SEATSMAX',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '최대용량',

        'S' 'FIELDNAME'   'SEATSOCC',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     '점유좌석',

        'S' 'FIELDNAME'   'PAYMENTSUM',
        ' ' 'OUTPUTLEN'   '22',
        ' ' 'EDIT'        'X',
        ' ' 'CFIELDNAME'  'CURRENCY',
        'E' 'COLTEXT'     '예약 총계',

        'S' 'FIELDNAME'   'SEATSMAX_B',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     'MAX. Business Class',

        'S' 'FIELDNAME'   'SEATSOCC_B',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     'OCC. Business Class',

        'S' 'FIELDNAME'   'SEATSMAX_F',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     'MAX. First Class',

        'S' 'FIELDNAME'   'SEATSOCC_F',
        ' ' 'OUTPUTLEN'   '10',
        ' ' 'EDIT'        'X',
        'E' 'COLTEXT'     'OCC. First Class'.

ENDFORM.                    " SET_FIELDCATLOG_DATA
*&---------------------------------------------------------------------*
*&      Form  fill_field_category
*&---------------------------------------------------------------------*
FORM fill_field_category USING pv_gub pv_fname pv_con.

  IF pv_gub = 'S'.
    CLEAR gs_fieldcat.
  ENDIF.

* 속성 MOVE
  DATA lv_col(40).
  FIELD-SYMBOLS <fs>.
  CONCATENATE 'GS_FIELDCAT-' pv_fname  INTO lv_col.
  ASSIGN      (lv_col)       TO        <fs>.
  MOVE         pv_con        TO        <fs>.

  IF pv_gub = 'E'.
    APPEND gs_fieldcat TO gt_fieldcat.
  ENDIF.
ENDFORM. " fill_field_category
*&---------------------------------------------------------------------*
*&      Form  REGIST_ALV_EVENT_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM regist_alv_event_0100 USING pr_grid TYPE REF TO cl_gui_alv_grid.

  CASE gv_mode.

    WHEN 'S'.

      CALL METHOD pr_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 0.

    WHEN 'E'.

* REGISTER EVENT
      CALL METHOD pr_grid->register_edit_event
        EXPORTING
          i_event_id = cl_gui_alv_grid=>mc_evt_modified.
*
      CALL METHOD pr_grid->set_ready_for_input
        EXPORTING
          i_ready_for_input = 1.

  ENDCASE.

*-- GR_EVENT_RECEIVER
  IF gr_event_receiver IS INITIAL.
    CREATE OBJECT gr_event_receiver.
  ENDIF.

* Handler Event
  SET HANDLER:
    gr_event_receiver->handle_toolbar       FOR ALL INSTANCES,
    gr_event_receiver->handle_data_changed  FOR ALL INSTANCES,
    gr_event_receiver->handle_data_changed_finished
      FOR ALL INSTANCES,
    gr_event_receiver->handle_user_command  FOR ALL INSTANCES,
    gr_event_receiver->handle_hotspot_click FOR ALL INSTANCES,
    gr_event_receiver->handle_double_click  FOR ALL INSTANCES,
    gr_event_receiver->handle_onf4          FOR ALL INSTANCES.

  PERFORM set_f4 USING pr_grid.

ENDFORM.                    " REGIST_ALV_EVENT_0100
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_TITLE_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_alv_title_0100 .

  DATA: lv_title TYPE lvc_title.

  lv_title = TEXT-gt1.

  CALL METHOD gr_grid1->set_gridtitle
    EXPORTING
      i_gridtitle = lv_title.

ENDFORM.                    " DISPLAY_ALV_TITLE_0100
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_GRID_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_alv_grid_0100 .

  gs_variant-report = sy-repid.

  gv_save = 'A'.

  "*-- Build field catalog for the alv control
  CALL METHOD gr_grid1->set_table_for_first_display
    EXPORTING
      i_default                     = abap_true
      is_layout                     = gs_layout
      is_variant                    = gs_variant
      i_save                        = gv_save
      it_toolbar_excluding          = gt_exclude
    CHANGING
      it_fieldcatalog               = gt_fieldcat
      it_sort                       = gt_sort
      it_outtab                     = gt_display[]
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3.

  IF sy-subrc NE 0.
    MESSAGE e000(0k) WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " DISPLAY_ALV_GRID_0100
*&---------------------------------------------------------------------*
*&      Form  REFRESH_GRID_0100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM refresh_grid_0100 .

  gs_stable-row = abap_true. "Row
  gs_stable-col = abap_true. "column

  CALL METHOD gr_grid1->refresh_table_display
    EXPORTING
      is_stable      = gs_stable
      i_soft_refresh = space.

  CALL METHOD cl_gui_cfw=>flush.

ENDFORM.                    " REFRESH_GRID_0100
*&---------------------------------------------------------------------*
*&      Form  GET_GRID_CURSOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_grid_cursor USING pr_sender TYPE REF TO cl_gui_alv_grid
                   CHANGING pv_row
                            pv_col.

  DATA: lv_row    TYPE i,
        lv_value  TYPE c,
        lv_col    TYPE i,
        ls_row_id TYPE lvc_s_row,
        ls_col_id TYPE lvc_s_col,
        ls_row_no TYPE lvc_s_roid.

  CLEAR: pv_row, pv_col.

  CALL METHOD pr_sender->get_current_cell
    IMPORTING
      e_row     = lv_row
      e_value   = lv_value
      e_col     = lv_col
      es_row_id = ls_row_id
      es_col_id = ls_col_id
      es_row_no = ls_row_no.

  " ROW RETURN
  pv_row = lv_row.

  " COL RETURN
  pv_col = lv_col.


ENDFORM.                    "GET_GRID_CURSOR
*&---------------------------------------------------------------------*
*&      Form  SET_GRID_CURSOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_grid_cursor USING pr_sender TYPE REF TO cl_gui_alv_grid
                           pv_row
                           pv_col.

  DATA: ls_row_id    TYPE lvc_s_row,
        ls_column_id TYPE lvc_s_col,
        ls_row_no    TYPE lvc_s_roid.

  IF pv_row IS NOT INITIAL AND pv_row > 0.
    ls_row_id-index = pv_row.
  ENDIF.

  IF pv_col IS NOT INITIAL.
    ls_column_id-fieldname = pv_col.
  ENDIF.

  CALL METHOD pr_sender->set_current_cell_via_id
    EXPORTING
      is_row_id    = ls_row_id
      is_column_id = ls_column_id
      is_row_no    = ls_row_no.

ENDFORM.                    " SET_GRID_CURSOR
*&---------------------------------------------------------------------*
*&      Form  CHECKED_SAVED_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM checked_saved_data .

  DATA: BEGIN OF ls_key,
          gjahr TYPE gjahr,
          kokrs TYPE kokrs,
          kostl TYPE kostl,
          posid TYPE ps_posid,
        END OF ls_key,
        lt_key LIKE SORTED TABLE OF ls_key
                    WITH UNIQUE KEY gjahr kokrs kostl posid.

  CALL METHOD gr_grid1->check_changed_data( ).

  CLEAR gv_exit.

  "-- 중복키 CHECK LOGIC.
  LOOP AT gt_display INTO gs_display.
    MOVE-CORRESPONDING gs_display TO ls_key.
    INSERT ls_key INTO TABLE lt_key.
    IF sy-subrc NE 0.
      gv_exit = abap_true.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gv_exit EQ abap_true.
    MESSAGE s017 WITH ls_key-gjahr ls_key-kokrs ls_key-kostl
                      ls_key-posid
      DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  LOOP AT gt_display INTO gs_display.

    IF gs_display-kostl IS NOT INITIAL AND
       gs_display-posid IS NOT INITIAL.

      MESSAGE s000 WITH TEXT-e02 DISPLAY LIKE 'E'.
      gv_exit = abap_true.
      EXIT.

    ENDIF.
    IF gs_display-kostl   IS  INITIAL AND
       gs_display-posid   IS  INITIAL.

      MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE 'E'.
      gv_exit = abap_true.
      EXIT.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " CHECKED_SAVED_DATA
*&---------------------------------------------------------------------*
*&      Form  POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
FORM popup_to_confirm USING pv_title
                            pv_quest.

  "-- call popup
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = pv_title                "TEXT-PT1
*     DIAGNOSE_OBJECT             = ' '
      text_question  = pv_quest                "TEXT-QT1
*     TEXT_BUTTON_1  = 'Ja'(001)
*     ICON_BUTTON_1  = ' '
*     TEXT_BUTTON_2  = 'Nein'(002)
*     ICON_BUTTON_2  = ' '
*     DEFAULT_BUTTON = '1'
*     DISPLAY_CANCEL_BUTTON       = 'X'
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN   = 25
*     START_ROW      = 6
*     POPUP_TYPE     =
*     IV_QUICKINFO_BUTTON_1       = ' '
*     IV_QUICKINFO_BUTTON_2       = ' '
    IMPORTING
      answer         = gv_answer
*   TABLES
*     PARAMETER      =
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " POPUP_TO_CONFIRM
*&---------------------------------------------------------------------*
*&      Form  SAVE_DATA_RTN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM save_data_rtn .

  DATA: lv_message TYPE string.

  DATA: lt_zcot0030 TYPE TABLE OF zcot0030 WITH HEADER LINE.

  LOOP AT gt_display INTO gs_display.

    MOVE-CORRESPONDING gs_display TO lt_zcot0030.

    lt_zcot0030-erdat = sy-datum.
    lt_zcot0030-erzet = sy-uzeit.
    lt_zcot0030-ernam = sy-uname.
    lt_zcot0030-aedat = sy-datum.
    lt_zcot0030-aezet = sy-uzeit.
    lt_zcot0030-aenam = sy-uname.
    lt_zcot0030-kokrs = pa_kokrs.

    APPEND lt_zcot0030.
    CLEAR  lt_zcot0030.

  ENDLOOP.

  TRY .

      DELETE FROM zcot0030 WHERE kokrs  = @pa_kokrs
                             AND gjahr  = @pa_gjahr.

      INSERT zcot0030 FROM TABLE lt_zcot0030.

      COMMIT WORK.

      MESSAGE s007.

      CLEAR gt_display_log.

      gt_display_log[] = gt_display[].

    CATCH cx_sy_sql_error INTO DATA(lr_error).

      ROLLBACK WORK.

      lv_message = lr_error->get_text( ).
      MESSAGE s001 WITH lv_message DISPLAY LIKE 'E'.

  ENDTRY.

ENDFORM.                    " SAVE_DATA_RTN
*&---------------------------------------------------------------------*
*& Form CHECK_CONTROLLING_AREA
*&---------------------------------------------------------------------*
FORM check_controlling_area .

  SELECT SINGLE bezei INTO @pa_ktxt
    FROM tka01
   WHERE kokrs = @pa_kokrs.

  IF sy-subrc <> 0.
    SET CURSOR FIELD 'PA_KOKRS'.
    MESSAGE e027  WITH pa_kokrs.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4
*&---------------------------------------------------------------------*
FORM set_f4 USING pr_grid TYPE REF TO cl_gui_alv_grid.

  CLEAR : gs_f4, gt_f4, gt_f4[].
  gs_f4-fieldname = 'KAGRU'.
  gs_f4-register  = 'X'.
  INSERT gs_f4 INTO TABLE gt_f4.

  CALL METHOD pr_grid->register_f4_for_fields
    EXPORTING
      it_f4 = gt_f4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIAL_SET
*&---------------------------------------------------------------------*
FORM initial_set .

  CASE sy-tcode.
    WHEN 'ZCOR0051'.
      gv_mode = 'S'.
    WHEN OTHERS.
      gv_mode = 'E'.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TOP_OF_PAGE_CREATE_OBJECT_0100
*&---------------------------------------------------------------------*
FORM top_of_page_create_object_0100 .

* Create TOP-Document
  CREATE OBJECT gr_top_document
    EXPORTING
      style = 'ALV_GRID'.

* Initialize
  CALL METHOD gr_top_document->initialize_document( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_TOP_OF_PAGE_DATA_0100
*&---------------------------------------------------------------------*
FORM make_top_of_page_data_0100 .

  DATA: lt_texts TYPE sdydo_text_table,
        lv_text  TYPE sdydo_text_element.

  CONCATENATE TEXT-001 ':' pa_kokrs
        INTO lv_text SEPARATED BY space.

  CALL METHOD gr_top_document->add_text
    EXPORTING
      text         = lv_text
      sap_color    = cl_dd_document=>list_heading_int
      sap_emphasis = cl_dd_area=>key
      style_class  = space.

  CALL METHOD gr_top_document->new_line.

  CONCATENATE TEXT-c01 ':' pa_gjahr
        INTO lv_text SEPARATED BY space.

  CALL METHOD gr_top_document->add_text
    EXPORTING
      text         = lv_text
      sap_color    = cl_dd_document=>list_heading_int
      sap_emphasis = cl_dd_area=>key
      style_class  = space.

  CALL METHOD gr_top_document->new_line
    EXPORTING
      repeat = 1.

*  CALL METHOD GR_TOP_DOCUMENT->ADD_GAP
*    EXPORTING
*      WIDTH = 20.

  " Get Ready
  CALL METHOD gr_top_document->merge_document.

*" Display TOP document
  CALL METHOD gr_top_document->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = gr_parent_html
    EXCEPTIONS
      html_display_error = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_CHANGE
*&---------------------------------------------------------------------*
FORM check_change  CHANGING p_gv_valid.

  IF gt_display_log[] = gt_display[].
    CLEAR p_gv_valid.
  ELSE.
    p_gv_valid = abap_true.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCRFIELDS_FUNCTXT
*&---------------------------------------------------------------------*
FORM scrfields_functxt .

  gs_funtxt-icon_id   = icon_information.
  gs_funtxt-quickinfo = 'Program Help'.

  sscrfields-functxt_01 = gs_funtxt.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SCR_USER_COMMAND
*&---------------------------------------------------------------------*
FORM scr_user_command .

  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      PERFORM call_popup_help(zcar9000) USING sy-repid
                                              sy-dynnr
                                              sy-langu ''.
    WHEN OTHERS.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EDIT_SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM edit_select_data .


  DATA : ls_color TYPE lvc_s_scol.

  DATA: gl_row    TYPE i,
        gl_value  TYPE c,
        gl_col    TYPE i,
        gl_row_id TYPE lvc_s_row,
        gl_col_id TYPE lvc_s_col,
        gl_row_no TYPE lvc_s_roid.




  IF lines( gt_rows ) > 0.



    CLEAR : gs_rows , gs_display .


    LOOP AT gt_rows INTO gs_rows.

      READ TABLE gt_display ASSIGNING FIELD-SYMBOL(<fs_disp>) INDEX gs_rows-index.

      IF sy-subrc EQ 0.

        CLEAR ls_color.
        CLEAR gt_style[].

        IF gl_col_id IS NOT INITIAL.
          _style_enabled   gl_col_id.
        ELSE.
          _style_enabled : 'KOSTL'.
          _style_enabled : 'POSID'.
          _style_enabled : 'BEXCL'.

        ENDIF.


        <fs_disp>-style[] = gt_style[].

        CLEAR <fs_disp>-cellcolor.


        CLEAR gt_style[].

      ENDIF.
    ENDLOOP .


  ENDIF.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form ADD_DATA_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM add_data_rtn .



  DATA : ls_color TYPE lvc_s_scol.
  DATA: gl_row    TYPE i,
        gl_value  TYPE c,
        gl_col    TYPE i,
        gl_row_id TYPE lvc_s_row,
        gl_col_id TYPE lvc_s_col,
        gl_row_no TYPE lvc_s_roid.

  DATA : lv_flag(1).


*  CALL METHOD gr_grid1->get_current_cell
*    IMPORTING
*      e_row     = gl_row
*      e_value   = gl_value
*      e_col     = gl_col
*      es_row_id = gl_row_id
*      es_col_id = gl_col_id
*      es_row_no = gl_row_no.


  DATA(lt_display) = gt_display[].

  READ TABLE gt_display INTO gs_display INDEX 1.
  CLEAR : gs_display-bexcl,
          gs_display-kostl,
          gs_display-posid.


  CLEAR: gt_display, gt_display[].


*ADD ROW 무조건 1 행으로 요청 < 강현수K

  CLEAR ls_color.
  CLEAR gt_style[].

  _style_enabled : 'KOSTL'.
  _style_enabled : 'BEXCL'.
  _style_enabled : 'POSID'.

  gs_display-icon = icon_yellow_light .

  gs_display-style[] = gt_style[].

  CLEAR gs_display-cellcolor.
  gs_display-bexcl =  abap_true.

  APPEND gs_display TO gt_display.


  LOOP AT lt_display ASSIGNING  FIELD-SYMBOL(<fs>).


    APPEND <fs> TO gt_display.



  ENDLOOP.





ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELE_SELECT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM dele_select_data .

  DATA : lt_0030 TYPE TABLE OF zcot0030,
         ls_0030 LIKE LINE OF lt_0030.

  DATA : lt_0030log TYPE TABLE OF zcot0030log,
         ls_0030log LIKE LINE OF lt_0030log.

  DATA : ls_color TYPE lvc_s_scol.


  DATA: lv_timestamp LIKE tzonref-tstampl.


  DATA exp        TYPE sxmsmguid.
  DATA imp        TYPE int4.
  DATA lv_stamp2  TYPE int4.

  CLEAR gv_answer.

  "-- call popup
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '확인'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = '선택한 자료를  삭제 합니다.'
*     TEXT_BUTTON_1         = 'Ja'(001)
*     ICON_BUTTON_1         = ' '
*     TEXT_BUTTON_2         = 'Nein'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = ' '
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = gv_answer
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK  gv_answer = '1'.

  LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<zz>).
    CLEAR <zz>-mark.
  ENDLOOP.

  CLEAR gv_succnt.
  CLEAR gv_falcnt..

  CLEAR : gs_rows , gs_display .
  CLEAR : lt_0030, lt_0030[].

  LOOP AT gt_rows INTO gs_rows.

    READ TABLE gt_display ASSIGNING <fs_disp> INDEX gs_rows-index.

    CHECK  sy-subrc EQ 0.
    <fs_disp>-mark = 'X'.

    SELECT SINGLE *
      FROM zcot0030
     WHERE gjahr  = @pa_gjahr
       AND kokrs  = @pa_kokrs
       AND kostl  = @<fs_disp>-kostl
       AND posid  = @<fs_disp>-posid
    INTO CORRESPONDING FIELDS OF @ls_0030.
    IF sy-subrc EQ 0.

      DELETE   FROM zcot0030
               WHERE gjahr  = @pa_gjahr
                AND kokrs  = @pa_kokrs
                AND kostl  = @<fs_disp>-kostl
                AND posid  = @<fs_disp>-posid.

      IF sy-subrc EQ 0.

        CLEAR lv_timestamp.
        CALL FUNCTION 'RRBA_GET_TIME'
          IMPORTING
            e_timestampl = lv_timestamp.

        CLEAR ls_0030log.
        MOVE-CORRESPONDING <fs_disp> TO ls_0030log.

        ls_0030log-tstampl = sy-datum && sy-uzeit && lv_timestamp.

        ls_0030log-flag = 'D'.
        ls_0030log-erdat = sy-datum.  "삭제 실행일
        ls_0030log-erzet = sy-uzeit.
        ls_0030log-ernam = sy-uname.

        INSERT zcot0030log FROM ls_0030log.

        IF sy-subrc EQ 0.
          COMMIT WORK AND WAIT.
          gv_succnt =  gv_succnt + 1.

        ELSE.

          gv_falcnt = gv_falcnt + 1.
          ROLLBACK WORK .
        ENDIF.

      ELSE.

        gv_falcnt = gv_falcnt + 1.
        ROLLBACK WORK .

      ENDIF.

      MESSAGE s000 WITH gv_succnt '건 삭제성공'  gv_falcnt '건 삭제실패'.

    ELSE.


    ENDIF.

  ENDLOOP .


  DELETE gt_display WHERE mark = 'X'.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_SELECT_DATA_NEW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM save_select_data_new .


  DATA : lt_0030 TYPE TABLE OF zcot0030,
         ls_0030 LIKE LINE OF lt_0030.

  DATA : lt_0030log TYPE TABLE OF zcot0030log,
         ls_0030log LIKE LINE OF lt_0030log.

  DATA : ls_color TYPE lvc_s_scol.


  DATA: lv_timestamp LIKE tzonref-tstampl.


  DATA exp        TYPE sxmsmguid.
  DATA imp        TYPE int4.
  DATA lv_stamp2  TYPE int4.

  CLEAR gv_answer.

  "-- call popup
  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar              = '확인'
*     DIAGNOSE_OBJECT       = ' '
      text_question         = '선택한 자료를 저장 합니다.'
*     TEXT_BUTTON_1         = 'Ja'(001)
*     ICON_BUTTON_1         = ' '
*     TEXT_BUTTON_2         = 'Nein'(002)
*     ICON_BUTTON_2         = ' '
*     DEFAULT_BUTTON        = '1'
      display_cancel_button = ' '
*     USERDEFINED_F1_HELP   = ' '
*     START_COLUMN          = 25
*     START_ROW             = 6
*     POPUP_TYPE            =
*     IV_QUICKINFO_BUTTON_1 = ' '
*     IV_QUICKINFO_BUTTON_2 = ' '
    IMPORTING
      answer                = gv_answer
*   TABLES
*     PARAMETER             =
    EXCEPTIONS
      text_not_found        = 1
      OTHERS                = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK  gv_answer = '1'.

  LOOP AT gt_display ASSIGNING FIELD-SYMBOL(<zz>).
    CLEAR <zz>-mark.
  ENDLOOP.

  CLEAR gv_succnt.
  CLEAR gv_falcnt..

  CLEAR : gs_rows , gs_display .
  CLEAR : lt_0030, lt_0030[].
  CLEAR : lt_0030log, lt_0030log[].

  CLEAR gv_exit.

  LOOP AT gt_rows INTO gs_rows.

    READ TABLE gt_display ASSIGNING FIELD-SYMBOL(<fs>) INDEX gs_rows-index.

    CHECK  sy-subrc EQ 0.
    <fs>-mark = 'X'.

**기존 저장시 체크로직

    IF <fs>-kostl IS NOT INITIAL AND
       <fs>-posid IS NOT INITIAL.

      MESSAGE s000 WITH TEXT-e02 DISPLAY LIKE 'E'.
      gv_exit = abap_true.
      EXIT.

    ENDIF.
    IF <fs>-kostl   IS  INITIAL AND
       <fs>-posid   IS  INITIAL.

      MESSAGE s000 WITH TEXT-e03 DISPLAY LIKE 'E'.
      gv_exit = abap_true.
      EXIT.

    ENDIF.
  ENDLOOP.


  CHECK gv_exit IS INITIAL.


  LOOP AT gt_display ASSIGNING <fs_disp> WHERE mark = 'X'.

    SELECT SINGLE *
      FROM zcot0030
     WHERE gjahr = @pa_gjahr
       AND kokrs = @pa_kokrs
       AND kostl = @<fs_disp>-kostl
       AND posid = @<fs_disp>-posid
    INTO CORRESPONDING FIELDS OF @ls_0030.

    CASE  sy-subrc.
      WHEN 0.   " 수정 UPDATE..

        CLEAR ls_0030.
        MOVE-CORRESPONDING <fs_disp> TO ls_0030.
        ls_0030-kokrs = pa_kokrs.

        ls_0030-aedat = sy-datum.
        ls_0030-aezet = sy-uzeit.
        ls_0030-aenam = sy-uname.

        MODIFY  zcot0030 FROM ls_0030.

        IF sy-subrc EQ 0.

          CLEAR lv_timestamp.
          CALL FUNCTION 'RRBA_GET_TIME'
            IMPORTING
              e_timestampl = lv_timestamp.

          CLEAR ls_0030log.
          MOVE-CORRESPONDING ls_0030 TO ls_0030log.

          ls_0030log-tstampl = sy-datum && sy-uzeit && lv_timestamp.

          ls_0030log-flag = 'U'.
          ls_0030log-kokrs = pa_kokrs.
          ls_0030log-aedat = sy-datum.
          ls_0030log-aezet = sy-uzeit.
          ls_0030log-aenam = sy-uname.

          MODIFY zcot0030log FROM ls_0030log.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
            gv_succnt =  gv_succnt + 1.

          ELSE.

            gv_falcnt = gv_falcnt + 1.
            ROLLBACK WORK .
          ENDIF.

        ENDIF.

      WHEN OTHERS.  " 신규 저장  INSERT .

        CLEAR ls_0030.
        MOVE-CORRESPONDING <fs_disp> TO ls_0030.
        ls_0030-kokrs = pa_kokrs.

        ls_0030-erdat = sy-datum.
        ls_0030-erzet = sy-uzeit.
        ls_0030-ernam = sy-uname.

        MODIFY  zcot0030 FROM ls_0030.


        IF sy-subrc EQ 0.

          CLEAR lv_timestamp.
          CALL FUNCTION 'RRBA_GET_TIME'
            IMPORTING
              e_timestampl = lv_timestamp.

          CLEAR ls_0030log.
          MOVE-CORRESPONDING <fs_disp> TO ls_0030log.

          ls_0030log-tstampl = sy-datum && sy-uzeit && lv_timestamp.

          ls_0030log-flag = 'I'.
          ls_0030log-kokrs = pa_kokrs.
          ls_0030log-erdat = sy-datum.
          ls_0030log-erzet = sy-uzeit.
          ls_0030log-ernam = sy-uname.

          MODIFY  zcot0030log FROM ls_0030log.

          IF sy-subrc EQ 0.
            COMMIT WORK AND WAIT.
            gv_succnt =  gv_succnt + 1.

          ELSE.

            gv_falcnt = gv_falcnt + 1.
            ROLLBACK WORK .
          ENDIF.

        ENDIF.

    ENDCASE.

    CLEAR gt_style[].

    _style_disabled : 'KOSTL'.
    _style_disabled : 'POSID'.
    _style_disabled : 'BEXCL'.

    <fs_disp>-icon = icon_led_green.

    <fs_disp>-style[] = gt_style[].

  ENDLOOP .

  MESSAGE s000 WITH gv_succnt '건 저장성공'  gv_falcnt '건 저장실패'.

ENDFORM.
