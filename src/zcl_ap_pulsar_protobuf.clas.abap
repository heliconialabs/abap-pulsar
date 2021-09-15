CLASS zcl_ap_pulsar_protobuf DEFINITION PUBLIC.
  PUBLIC SECTION.
* https://github.com/apache/pulsar/blob/master/pulsar-common/src/main/proto/PulsarApi.proto#L262
    TYPES: BEGIN OF command_connect,
              client_version   TYPE string,  " field 1
              auth_method_name TYPE string,  " field 5
              auth_data        TYPE xstring, " field 3
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
* todo

    zcl_protobuf=>create( ).

    WRITE / output.
  ENDMETHOD.

  METHOD command_connect_deserialize.
    RETURN. " todo
  ENDMETHOD.

ENDCLASS.