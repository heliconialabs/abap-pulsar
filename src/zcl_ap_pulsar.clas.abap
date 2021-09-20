CLASS zcl_ap_pulsar DEFINITION PUBLIC CREATE PRIVATE.
  PUBLIC SECTION.
    INTERFACES zif_ap_pulsar.
    INTERFACES if_apc_wsp_event_handler.
    CLASS-METHODS connect
      IMPORTING
        iv_host          TYPE string
        iv_port          TYPE string
      RETURNING
        VALUE(ri_pulsar) TYPE REF TO zif_ap_pulsar
      RAISING
        cx_static_check.
  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mi_client TYPE REF TO if_apc_wsp_client.
    DATA mv_on_message TYPE xstring.
    METHODS send
      IMPORTING
        iv_message TYPE xstring
      RAISING
        cx_apc_error.
ENDCLASS.



CLASS ZCL_AP_PULSAR IMPLEMENTATION.


  METHOD connect.
    DATA ls_frame TYPE if_abap_channel_types=>ty_apc_tcp_frame.

    DATA(lo_pulsar) = NEW zcl_ap_pulsar( ).

* todo, set ls_frame

    lo_pulsar->mi_client = cl_apc_tcp_client_manager=>create(
      i_host          = iv_host
      i_port          = iv_port
      i_frame         = ls_frame
      i_event_handler = lo_pulsar ).

    lo_pulsar->mi_client->connect( ).

    ri_pulsar = lo_pulsar.
  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_close.
    WRITE / 'on_close'.
  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_error.
    WRITE / 'on_error'.
  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_message.
    WRITE / 'on_message, received:'.
    TRY.
        mv_on_message = i_message->get_binary( ).
      CATCH cx_root.
    ENDTRY.
    WRITE / mv_on_message.
  ENDMETHOD.


  METHOD if_apc_wsp_event_handler~on_open.
    WRITE / 'on_open'.
  ENDMETHOD.


  METHOD send.

    DATA li_message_manager TYPE REF TO if_apc_wsp_message_manager.
    DATA li_message         TYPE REF TO if_apc_wsp_message.

    li_message_manager = mi_client->get_message_manager( ).
    li_message = li_message_manager->create_message( ).
    li_message->set_binary( iv_message ).
    li_message_manager->send( li_message ).

    WAIT FOR PUSH CHANNELS
      UNTIL mv_on_message IS NOT INITIAL
      UP TO 10 SECONDS.

  ENDMETHOD.


  METHOD zif_ap_pulsar~close.
    mi_client->close( ).
  ENDMETHOD.


  METHOD zif_ap_pulsar~connect.
* https://github.com/apache/pulsar/blob/master/pulsar-common/src/main/proto/PulsarApi.proto#L262
* https://pulsar.apache.org/docs/en/develop-binary-protocol/#connection-establishment

    DATA lv_total_size   TYPE x LENGTH 4.
    DATA lv_command_size TYPE x LENGTH 4.

    DATA(lv_message) = NEW zcl_ap_pulsar_protobuf( )->command_connect_serialize( VALUE #(
      client_version   = 'abap-pulsar'
      protocol_version = 17 ) ).
    lv_command_size = xstrlen( lv_message ).
    lv_total_size = lv_command_size + 4.

    CONCATENATE lv_total_size lv_command_size lv_message INTO lv_message IN BYTE MODE.

    send( lv_message ).

  ENDMETHOD.
ENDCLASS.
