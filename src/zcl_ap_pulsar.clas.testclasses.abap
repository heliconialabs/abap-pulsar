CLASS ltcl_test DEFINITION FOR TESTING RISK LEVEL HARMLESS DURATION SHORT FINAL.
  PRIVATE SECTION.
    METHODS test1 FOR TESTING RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_test IMPLEMENTATION.
  METHOD test1.
    DATA(li_pulsar) = zcl_ap_pulsar=>connect(
      iv_host = 'localhost'
      iv_port = '6650' ).

* send connect command
    li_pulsar->connect( ).

    li_pulsar->close( ).
  ENDMETHOD.
ENDCLASS.