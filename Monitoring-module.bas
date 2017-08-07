'--------------------------------------------------------------
'                   Thomas Jensen | uCtrl.io
'--------------------------------------------------------------
'  file: AVR_MONITORING_MODULE
'  date: 12/03/2006
'--------------------------------------------------------------
$regfile = "2313def.dat"
$crystal = 4000000
Config Portd = Input
Config Portb = Output
Config Watchdog = 1024

Dim Feil As Integer
Dim Feil_prev As Integer
Dim Timeout As Integer
Dim Horn As Integer
Dim Nettspenning As Integer
Dim Lifesignal As Integer

Timeout = 3100
Lifesignal = 31

Portb = 0
Portb.2 = 1
Waitms 1000
Portb.3 = 1
Waitms 1000
Portb.6 = 1
Waitms 1000
Portb.4 = 1
Waitms 1000
Start Watchdog
Portb = 0


Main:
If Pind.3 = 0 Then                                          'emergency supply NC
   Feil = 1
   Nettspenning = 1
   Waitms 100
   End If

If Pind.5 = 1 Then                                          '12V supply NO
   Feil = 1
   Portb.3 = 1
   Waitms 100
   Portb.3 = 0
   End If

If Pind.4 = 1 Then                                          '5V supply NO
   Feil = 1
   Portb.3 = 1
   Waitms 100
   Portb.3 = 0
   End If

If Pind.2 = 0 Then                                          'fuse failure
   Feil = 1
   Portb.2 = 1
   Waitms 100
   Portb.2 = 0
   End If

If Pind.0 = 0 And Timeout = 0 Then                          'set timeout timer
   Timeout = 3100
   End If

If Timeout > 0 Then Timeout = Timeout - 1                   'timeout timer
If Timeout = 0 Then
   Feil = 1
   Portb.6 = 1
   Waitms 100
   Portb.6 = 0
   End If
If Pind.0 = 0 Then Timeout = 3100

If Horn > 0 Then Horn = Horn - 1                            'horn
If Horn = 6 Then Portb.0 = 1
If Horn = 1 Then Portb.0 = 0

If Feil = 1 And Feil_prev = 0 Then Horn = 10                'failure output signal
If Feil = 1 Then
   Portb.1 = 1
   Feil_prev = 1
   If Timeout > 0 Then Timeout = Timeout - 1
   End If
If Feil = 0 Then
   Portb.1 = 0
   Feil_prev = 0
   End If

If Nettspenning = 1 Then Portb.3 = 1                        'emergency supply set
If Nettspenning = 0 Then Portb.3 = 0

Feil = 0
Nettspenning = 0

If Lifesignal > 0 Then Lifesignal = Lifesignal - 1          'lifesignal
If Lifesignal = 6 Then Portb.5 = 1
If Lifesignal = 1 Then Portb.5 = 0
If Lifesignal = 0 Then Lifesignal = 31

Reset Watchdog                                              'loop cycle
Portb.4 = 1
Waitms 25
Portb.4 = 0
Waitms 75
Goto Main
End