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
mtype lightState3 = DANGER;
mtype lightState4 = DANGER;

ltl safetyProp { [](! lightState1 == PROCEED && lightState3 == PROCEED) && (lightState2 == PROCEED && lightState4 == PROCEED )}
ltl rProp1 { [] (lightState1 == PROCEED -> <> (lightState1 == DANGER))}
ltl rProp2 { [] (lightState2 == PROCEED -> <> (lightState2 == DANGER))}
ltl rProp3 { [] (lightState3 == PROCEED -> <> (lightState3 == DANGER))}
ltl rProp4 { [] (lightState4 == PROCEED -> <> (lightState4 == DANGER))}

// Safety Monitor Declaration...
active proctype SafetyMonitor() {
  do
  :: (lightState1 == PROCEED && lightState3 == PROCEED) && (lightState2 == PROCEED && lightState4 == PROCEED) ->
     printf("Safety Violation: North-South and West-East traffic signalled to proceed at the same time!\n");
     assert(0); // Raise an error
  od
}

// Central Controller Declaration..
proctype CentralControl() {
  bool go = true;
  do
  :: go ->
       atomic {
         controlToLight1 ! DANGER;
         controlToLight2 ! PROCEED;
         controlToLight3 ! DANGER;
         controlToLight4 ! PROCEED;
         lightState1 = DANGER;
         lightState2 = PROCEED;
         lightState3 = DANGER;
         lightState4 = PROCEED;
       }
       go = false;
  :: else ->
       atomic {
         controlToLight1 ! PROCEED;
         controlToLight2 ! DANGER;
         controlToLight3 ! PROCEED;
         controlToLight4 ! DANGER;
         lightState1 = PROCEED;
         lightState2 = DANGER;
         lightState3 = PROCEED;
         lightState4 = DANGER;
       }
       go = true;
  od;
}

// Traffic Light Proccess Declaration.
proctype TrafficLight(chan controlToLight, lightState,lightNumber) {
  do
  :: controlToLight ? lightState ->
     // Update the local light state
     if
       :: lightNumber == 1 -> lightState1 = lightState;
       :: lightNumber == 2 -> lightState2 = lightState;
       :: lightNumber == 3 -> lightState3 = lightState;
       :: lightNumber == 4 -> lightState4 = lightState;
     fi
  od
}

init {
    run SafetyMonitor();
    run CentralControl();
    run TrafficLight(controlToLight1, lightState1, 1); //North
    run TrafficLight(controlToLight2, lightState2, 2); //West
    run TrafficLight(controlToLight3, lightState3, 3); //South
    run TrafficLight(controlToLight4, lightState4, 4); //East
}
