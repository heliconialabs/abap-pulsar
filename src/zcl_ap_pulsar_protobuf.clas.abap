CLASS zcl_ap_pulsar_protobuf DEFINITION PUBLIC.
  PUBLIC SECTION.
* https://github.com/apache/pulsar/blob/master/pulsar-common/src/main/proto/PulsarApi.proto#L262
    TYPES: BEGIN OF command_connect,
              client_version   TYPE string,  " field 1
              protocol_version TYPE i,       " field 4
           END OF command_connect.
    METHODS command_connect_serialize
      IMPORTING
        input TYPE command_connect
      RETURNING
        VALUE(output) TYPE xstring.
    METHODS command_connect_deserialize.
ENDCLASS.

CLASS zcl_ap_pulsar_protobuf IMPLEMENTATION.

  METHOD command_connect_serialize.
    ASSERT input-client_version IS NOT INITIAL.

    DATA(li_top) = NEW zcl_protobuf_stream( ).
* All commands associated with Pulsar's protocol are contained in a BaseCommand protobuf message
    li_top->encode_field_and_type( VALUE #(
      field_number = 1
      wire_type    = zcl_protobuf_stream=>gc_wire_type-varint ) ).
    li_top->encode_varint( 2 ). " Type = CONNECT

***

    DATA(li_sub) = NEW zcl_protobuf_stream( ).
* the actual connect,
    li_sub->encode_field_and_type( VALUE #(
      field_number = 1
      wire_type    = zcl_protobuf_stream=>gc_wire_type-length_delimited ) ).
    li_sub->encode_delimited( cl_abap_codepage=>convert_to( input-client_version ) ).

    li_sub->encode_field_and_type( VALUE #(
      field_number = 4
      wire_type    = zcl_protobuf_stream=>gc_wire_type-varint ) ).
    li_sub->encode_varint( input-protocol_version ).

***

    li_top->encode_field_and_type( VALUE #(
      field_number = 2
      wire_type    = zcl_protobuf_stream=>gc_wire_type-length_delimited ) ).
    li_top->encode_delimited( li_sub->get( ) ).

    output = li_top->get( ).
* sdf    WRITE '@KERNEL console.dir(output.get());'.
  ENDMETHOD.

  METHOD command_connect_deserialize.
    RETURN. " todo
  ENDMETHOD.

ENDCLASS.
