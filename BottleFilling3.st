PROGRAM BFSystem
  VAR
    MainConveyor AT %QX0.0 : BOOL;
    MainSwitch AT %QX0.6 : BOOL;
    FillerLamp AT %QX0.1 : BOOL;
    PushRod AT %QX0.7 : BOOL;
    DiscardLamp AT %QX0.2 : BOOL;
    NormalLamp AT %QX0.3 : BOOL;
    FillerOff AT %QX0.4 : BOOL;
  END_VAR
  VAR
    TON0 : TON;
    TON1 : TON;
    NC : CTU;
  END_VAR
  VAR
    NC0 AT %QW0 : INT;
    DC0 AT %QW1 : INT;
    Reset AT %QX0.5 : BOOL;
  END_VAR
  VAR
    DC : CTU;
    R_TRIG1 : R_TRIG;
    R_TRIG2 : R_TRIG;
  END_VAR

  MainConveyor := MainSwitch OR MainSwitch;
  FillerLamp := NOT(FillerOff) AND MainConveyor;
  DiscardLamp := PushRod AND MainConveyor;
  NormalLamp := NOT(DiscardLamp) AND MainConveyor;
  TON0(IN := FillerLamp, PT := T#3000ms);
  IF TON0.Q THEN
    FillerOff := TRUE; (*set*)
  END_IF;
  TON1(IN := FillerOff, PT := T#1000ms);
  IF TON1.Q THEN
    FillerOff := FALSE; (*reset*)
  END_IF;
  R_TRIG1(CLK := FillerOff AND NormalLamp);
  NC(CU := R_TRIG1.Q, R := Reset, PV := 15000);
  NC0 := NC.CV;
  R_TRIG2(CLK := FillerOff AND DiscardLamp);
  DC(CU := R_TRIG2.Q, R := Reset, PV := 15000);
  DC0 := DC.CV;
END_PROGRAM


CONFIGURATION Config0

  RESOURCE Res0 ON PLC
    TASK task0(INTERVAL := T#20ms,PRIORITY := 0);
    PROGRAM instance0 WITH task0 : BFSystem;
  END_RESOURCE
END_CONFIGURATION
