CLASS zcl_ap_pulsar DEFINITION PUBLIC CREATE PRIVATE.
  PUBLIC SECTION.
    INTERFACES zif_ap_pulsar.
    INTERFACES if_apc_wsp_event_handler.
    CLASS-METHODS connect
      IMPORTING
        iv_host TYPE string
        iv_port TYPE i
      RETURNING
        VALUE(ri_pulsar) TYPE REF TO zif_ap_pulsar
      RAISING
        cx_static_check.
  PRIVATE SECTION.
    DATA mi_client TYPE REF TO if_apc_wsp_client.
ENDCLASS.

CLASS zcl_ap_pulsar IMPLEMENTATION.
  METHOD connect.
    DATA ls_frame TYPE if_apc_tcp_frame_types=>ty_frame_type.

    WRITE iv_host.
    WRITE iv_port.

    DATA(lo_pulsar) = NEW zcl_ap_pulsar( ).

    lo_pulsar->mi_client = cl_apc_tcp_client_manager=>create(
      i_host          = 'localhost'
      i_port          = 6650
      i_frame         = ls_frame
      i_event_handler = lo_pulsar ).

    lo_pulsar->mi_client->connect( ).

    ri_pulsar = lo_pulsar.
  ENDMETHOD.

  METHOD zif_ap_pulsar~close.
    mi_client->close( ).
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_open.
    WRITE / 'on_open'.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_message.
    WRITE / 'on_message'.
* sdf   message = i_message->get_binary( ).
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_close.
    RETURN.
  ENDMETHOD.

  METHOD if_apc_wsp_event_handler~on_error.
    WRITE / 'on_error'.
  ENDMETHOD.
ENDCLASS.