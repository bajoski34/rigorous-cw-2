/***********************************************************************************/
/*                                                                                 */
/*                    Traffic Control Signalling System                            */
/*                                                                                 */
/*                              Olaobaju Abraham                                   */ 
/*                                                                                 */
/***********************************************************************************/
/*                                                                                 */
/* A simple traffic control signalling system with four traffic lights and a       */
/* control.                                                                        */
/*                                                                                 */
/***********************************************************************************/
mtype = { DANGER, PROCEED };

chan controlToLight1 = [1] of { mtype };
chan controlToLight2 = [1] of { mtype };
chan controlToLight3 = [1] of { mtype };
chan controlToLight4 = [1] of { mtype };

mtype lightState1 = DANGER;
mtype lightState2 = DANGER;

active proctype SafetyMonitor() {
  do
  :: (lightState1 == PROCEED && lightState3 == PROCEED) ||
     (lightState2 == PROCEED && lightState4 == PROCEED) ->
     printf("Safety Violation: North-South and West-East traffic signalled to proceed at the same time!\n");
     assert(0); // Raise an error
  od
}

proctype CentralControl() {
  do
  :: atomic {
       controlToLight1 ! DANGER;
       controlToLight2 ! PROCEED;
       controlToLight3 ! PROCEED;
       controlToLight4 ! DANGER;
       lightState1 = DANGER;
       lightState2 = PROCEED;
  }
  :: atomic {
       controlToLight1 ! PROCEED;
       controlToLight2 ! DANGER;
       controlToLight3 ! DANGER;
       controlToLight4 ! PROCEED;
       lightState1 = PROCEED;
       lightState2 = DANGER;
  }
  od
}

proctype TrafficLight(chan controlToLight, mtype lightState; int lightNumber) {
  do
  :: controlToLight ? lightState ->
     // Update the local light state
     if
       :: lightNumber == 1 -> lightState1 = lightState;
       :: lightNumber == 2 -> lightState2 = lightState;
     fi
  od
}

init {
  run SafetyMonitor();
  run CentralControl();
  run TrafficLight(controlToLight1, lightState1, 1);
  run TrafficLight(controlToLight2, lightState2, 2);
  run TrafficLight(controlToLight3, lightState3, 3);
  run TrafficLight(controlToLight4, lightState4, 4);
}
