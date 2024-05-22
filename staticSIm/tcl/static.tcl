# Define Options
set val(chan)      Channel/WirelessChannel  ;# Channel Type
set val(prop)      Propagation/TwoRayGround ;# Radio Propagation Model
set val(netif)     Phy/WirelessPhy          ;# Network Interface Type
set val(mac)       Mac/802_11               ;# MAC Type (note the corrected case: Mac instead of MAC)
set val(ifq)       Queue/DropTail/PriQueue  ;# Interface Queue Type
set val(ll)        LL                       ;# Link Layer Type
set val(ant)       Antenna/OmniAntenna      ;# Antenna Model
set val(ifqlen)    50                       ;# Max Packet in ifq
set val(n)         4                        ;# Number of Mobile Nodes
set val(rp)        DSDV                     ;# Routing Protocol
set val(x)         500
set val(y)         500

# Create Simulator
set ns_ [new Simulator]

# Create Trace Object
set traceout [open static.tr w]
$ns_ trace-all $traceout

# Create a NAM Trace File
set namout [open static.nam w]
$ns_ namtrace-all-wireless $namout $val(x) $val(y)

# Create Object Topology
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

# Create GOD for saving all configuration
create-god $val(n)

# Create Channel #1
set chan_1_ [new $val(chan)]

# Create node-config
$ns_ node-config -adhocRouting $val(rp) \
                 -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -phyType $val(netif) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace OFF \
                 -channel $chan_1_

# Create Nodes
for {set i 0} {$i < $val(n)} {incr i} {
    set node_($i) [$ns_ node]
}
$node_(0) color blue
$node_(1) color blue
$node_(2) color blue
$node_(3) color blue

# Set Nodes Position (Static)
$node_(0) set X_ 10.0
$node_(0) set Y_ 10.0
$node_(0) set Z_ 0.0
$node_(1) set X_ 10.0
$node_(1) set Y_ 400.0
$node_(1) set Z_ 0.0
$node_(2) set X_ 400.0
$node_(2) set Y_ 10.0
$node_(2) set Z_ 0.0
$node_(3) set X_ 400.0
$node_(3) set Y_ 400.0
$node_(3) set Z_ 0.0

# Create a TCP flow from n0 to n2 and n1 to n3
set tcp1 [new Agent/TCP]
$tcp1 set class_ 2
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(0) $tcp1
$ns_ attach-agent $node_(2) $sink1
$ns_ connect $tcp1 $sink1

set tcp2 [new Agent/TCP]
$tcp2 set class_ 2
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp2
$ns_ attach-agent $node_(3) $sink2
$ns_ connect $tcp2 $sink2

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
set ftp2 [new Application/FTP]
$ftp2 attach-agent $tcp2

$ns_ at 1.0 "$ftp1 start"
$ns_ at 2.0 "$ftp2 start"
$ns_ at 14.0 "$ftp1 stop"
$ns_ at 14.0 "$ftp2 stop"

# Define node size in nam editor
for {set i 0} {$i < $val(n)} {incr i} {
    $ns_ initial_node_pos $node_($i) 30
}

# End Simulation
for {set i 0} {$i < $val(n)} {incr i} {
    $ns_ at 15.0 "$node_($i) reset"
}
$ns_ at 15.00 "stop"
$ns_ at 15.00 "puts \"NS EXITING...\" ; $ns_ halt"

# Define Stop Procedure
proc stop {} {
    global ns_ traceout namout
    $ns_ flush-trace
    close $traceout
    close $namout
    exec nam static.nam &
    exit 0
}

puts "Starting Simulation....."
$ns_ run

