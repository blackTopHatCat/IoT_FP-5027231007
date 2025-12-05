# IoT_FP-5027231007
**Project**  : IoT LCD Class Reminder

**Function** : shows remaining time until next class and its name on the current day

**Mechanism** : One computer device acts as server with a running mosquitto and publish informations about the upcoming class. The ESP32 will listen and print out any messages that it receives onto LCD.
