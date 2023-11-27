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

chan control_to_north = [1] of { mtype };
chan control_to_south = [1] of { mtype };
chan control_to_east = [1] of { mtype };
chan control_to_west = [1] of { mtype };

#define p (control_to_north == PROCEED && control_to_south == PROCEED) && (control_to_east == PROCEED && control_to_west == PROCEED)
#define q !(p)

proctype TrafficMonitor() {
    mtype north, south, west, east;
    do
    :: control_to_north? north; control_to_south? south; control_to_west? west; control_to_east? east; (north == PROCEED && south == PROCEED && west == PROCEED && east == PROCEED ) ->
        printf("Invariant violation: North-South traffic both signaled to proceed!\n");
        assert(false); 
    od;
}

proctype TrafficLight(chan control_channel, initialAspect) {
    mtype ASPECT = initialAspect;

    do
    :: control_channel ? PROCEED ->
        ASPECT = PROCEED;
        printf("Traffic Light: Switched to PROCEED\n");
    :: control_channel ? DANGER ->
        ASPECT = DANGER;
        printf("Traffic Light: Switched to DANGER\n");
    od;
}

proctype CentralControl() {
    do
    :: true ->
        // Alternating control
        control_to_north!PROCEED; control_to_south!PROCEED;
        control_to_east!DANGER; control_to_west!DANGER;



        control_to_north!DANGER; control_to_south!DANGER;
        control_to_east!PROCEED; control_to_west!PROCEED;
    od;
}

ltl safetyConstraint { [] q }
ltl response1 { [] (control_to_north == PROCEED -> <> (control_to_north == DANGER)) }

init {
    atomic {
        run TrafficLight(control_to_north, PROCEED);
        run TrafficLight(control_to_south, PROCEED);
        run TrafficLight(control_to_east, DANGER);
        run TrafficLight(control_to_west, DANGER);
        run TrafficMonitor();
        run CentralControl();
    }
}
