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

mtype lightState = DANGER;

active proctype SafetyMonitor() {
  do
  :: (lightState == DANGER) ->
     // Check the safety constraint
     if
       :: (controlToLight1 ? DANGER; controlToLight2 ? DANGER; controlToLight3 ? DANGER; controlToLight4 ? DANGER) ->
            // All lights are displaying DANGER, no violation
       :: (controlToLight1 ? PROCEED; controlToLight2 ? PROCEED; controlToLight3 ? PROCEED; controlToLight4 ? PROCEED) ->
            // Violation: North-South and West-East are both signaled to proceed
            printf("Safety Violation: North-South and West-East traffic signalled to proceed at the same time!\n");
            assert(0); // Raise an error
     fi
  :: (lightState == PROCEED) ->
     // Update the light state
     controlToLight1 ! PROCEED;
     controlToLight2 ! PROCEED;
     controlToLight3 ! DANGER;
     controlToLight4 ! DANGER;
  od
}

proctype CentralControl() {
  do
  :: lightState = DANGER; // Set the state to DANGER
  :: lightState = PROCEED; // Set the state to PROCEED
  od
}

proctype TrafficLight(chan controlToLight, int lightNumber) {
  mtype aspect;

  do
  :: controlToLight ? aspect ->
     // Update the local light state
     lightState = aspect;
  od
}

init {
  run SafetyMonitor();
  run CentralControl();
  run TrafficLight(controlToLight1, 1);
  run TrafficLight(controlToLight2, 2);
  run TrafficLight(controlToLight3, 3);
  run TrafficLight(controlToLight4, 4);
}

