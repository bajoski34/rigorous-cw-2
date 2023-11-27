mtype = { DANGER, PROCEED };

chan control_to_north = [1] of { mtype };
chan control_to_south = [1] of { mtype };
chan control_to_east = [1] of { mtype };
chan control_to_west = [1] of { mtype };

proctype TrafficMonitor() {
    do
    :: control_to_north == PROCEED && control_to_south == PROCEED ->
        printf("Invariant violation: North-South traffic both signaled to proceed!\n");
        assert(0);
    :: control_to_east == PROCEED && control_to_west == PROCEED ->
        printf("Invariant violation: East-West traffic both signaled to proceed!\n");
        assert(0);
    od;
}

proctype TrafficLight(chan control_channel, mtype initialAspect) {
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
        // Simulating alternating control
        control_to_north!PROCEED; control_to_south!PROCEED;
        control_to_east!DANGER; control_to_west!DANGER;
        control_to_north!DANGER; control_to_south!DANGER;
        control_to_east!PROCEED; control_to_west!PROCEED;
    od;
}

ltl safetyConstraint { [](! (control_to_north == PROCEED && control_to_south == PROCEED) && ! (control_to_east == PROCEED && control_to_west == PROCEED)) }
ltl responseProperty { [] (control_to_north == PROCEED -> <> (control_to_north == DANGER)) }

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
