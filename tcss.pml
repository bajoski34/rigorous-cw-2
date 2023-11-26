mtype = { DANGER, PROCEED };

chan control_to_traffic1 = [2] of {mtype};
chan control_to_traffic2 = [2] of {mtype};
chan control_to_traffic3 = [2] of {mtype};
chan control_to_traffic4 = [2] of {mtype};

proctype Control() {
    do
    :: true ->
        // control logic
        control_to_traffic1!PROCEED;
        control_to_traffic2!PROCEED;
        control_to_traffic3!DANGER;
        control_to_traffic4!DANGER;
    od;
}

proctype TrafficLight(chan control_channel) {
    mtype state;
    do
    :: control_channel?state ->
        // Traffic light logic to handle the received state
        // Example: set the traffic light to display the received state
    od;
}

// Instances of TrafficLight for each traffic light.
proctype TrafficLight1() {
    TrafficLight(control_to_traffic1);
}

proctype TrafficLight2() {
    TrafficLight(control_to_traffic2);
}

proctype TrafficLight3() {
    TrafficLight(control_to_traffic3);
}

proctype TrafficLight4() {
    TrafficLight(control_to_traffic4);
}
