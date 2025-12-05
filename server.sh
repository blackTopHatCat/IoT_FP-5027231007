#!/bin/sh

set -e

INTERFACE='wlan0'
[[ $(ip address show dev "$INTERFACE") ]] || exit  # Interface check
REGEX_IP='[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'
ADDRESS="$(ip a show dev "$INTERFACE"| grep -w --colour=never -o -E "$REGEX_IP" | head -1)"

MQTT_CONF="$HOME/Sources/scripts/mosquitto.conf"
SCHEDULE_FILE="$HOME/Sources/scripts/schedule.csv"
MQTT_TOPIC='schedule/class'
MQTT_USER='user1'
MQTT_USERPASS='pass'

# Initialize mqtt server
init_mosquitto() {
  [[ "$(pgrep mosquitto)" ]] && echo "killing previous mosquitto daemon" && pkill mosquitto && sleep 1
  sed -i -r "s/$REGEX_IP/$ADDRESS/" $MQTT_CONF 
  echo "running mosquitto" && mosquitto -d -c $MQTT_CONF 
}

# Create topic for mqtt
sub_mqtt() {
  echo "creating topic $MQTT_TOPIC:"
  mosquitto_sub -v -t "$MQTT_TOPIC" -u "$MQTT_USER" -P "$MQTT_USERPASS" -h "$ADDRESS"
}

# Publish time occassionally 
pub_mqtt() {
  local mqtt_message ss s mm m hh h d res

  while true; do
    ss="$(date +%s)"
    s=$((ss%60))
    mm=$((ss/60))
    m=$((mm%60))
    hh=$((mm/60))
    h=$((hh%24+7))
    d="$(date +%a)"
    
    # Match the upcoming class
    res=$(awk -v d="$d" -v h="$h" -v m="$m" -F ',' \
    ' 
      {
        if ($1 == d) {
          if ($2 >= h) {
            if ($2 == h && $3 < m)
              next
            printf "%s in %s",$4,$5
            exit
          }
        }
      }; 
    ' $SCHEDULE_FILE)
    mosquitto_pub -t "$MQTT_TOPIC" -u "$MQTT_USER" -m "$res" -P "$MQTT_USERPASS" -h "$ADDRESS"
    sleep 5
    
    # Calc remaining time in hour:minute
    res=$(awk -v d="$d" -v h="$h" -v m="$m" -F ',' \
    ' 
      BEGIN { rh=0; rm=0; };
      {
        if ($1 == d) {
          if ($2 >= h) {
            rh = $2 - h;
            rm = $3 - m;
            if ($3 <= m) {
              rh -= 1;
              rm += 60;
            }
            printf "Due in %ih %im",rh,rm
            exit
          }
        }
      }; 
    ' $SCHEDULE_FILE)
    mosquitto_pub -t "$MQTT_TOPIC" -u "$MQTT_USER" -m "$res" -P "$MQTT_USERPASS" -h "$ADDRESS"
    sleep 5
  done
}

main() {
  init_mosquitto
  sub_mqtt &
  sleep 1 && pub_mqtt
}

main
