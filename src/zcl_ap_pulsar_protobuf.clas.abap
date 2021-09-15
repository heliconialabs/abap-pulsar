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

    DATA(li_stream) = NEW zcl_protobuf_stream( ).

    li_stream->encode_field_and_type( VALUE #(
      field_number = 1
      wire_type    = zcl_protobuf_stream=>gc_wire_type-length_delimited ) ).
    li_stream->encode_delimited( cl_abap_codepage=>convert_to( input-client_version ) ).

    li_stream->encode_field_and_type( VALUE #(
      field_number = 4
      wire_type    = zcl_protobuf_stream=>gc_wire_type-varint ) ).
    li_stream->encode_varint( input-protocol_version ).

    output = li_stream->get( ).
  ENDMETHOD.

  METHOD command_connect_deserialize.
    RETURN. " todo
  ENDMETHOD.

ENDCLASS.