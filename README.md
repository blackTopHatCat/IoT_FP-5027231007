# IoT_FP-5027231007
**Project**  : IoT LCD Class Reminder

**Function** : shows remaining time until next class and its name on the current day

**Mechanism** : One computer device acts as server with a running mosquitto and publish informations about the upcoming class. The ESP32 will listen and print out any messages that it receives onto LCD.

**Features** : 
- Could accurately count the remaining time before next class in (H hour M minute) format
- Long message from server could be wrapped around the limited LCD width (16x2) whenever it detects message with over 16 character count
- Schedule list could be updated during operation and see the change in real time
