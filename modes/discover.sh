# DISCOVER MODE #####################################################################################################
if [[ "$MODE" = "discover" ]]; then
  if [[ "$REPORT" = "1" ]]; then
    if [[ ! -z "$WORKSPACE" ]]; then
      WORKSPACE="$(echo $WORKSPACE | tr / -)"
      args="$args -w $WORKSPACE"
      LOOT_DIR="$INSTALL_DIR/loot/workspace/$WORKSPACE"
      echo -e "$OKBLUE[*]$RESET Saving loot to $LOOT_DIR $OKBLUE[$RESET${OKGREEN}OK${RESET}$OKBLUE]$RESET"
      mkdir -p "$LOOT_DIR/ips" "$LOOT_DIR/screenshots" "$LOOT_DIR/nmap" "$LOOT_DIR/notes" "$LOOT_DIR/reports" "$LOOT_DIR/output" "$LOOT_DIR/scans" 2> /dev/null
    fi
    OUT_FILE="$(echo $TARGET | tr / -)"
    echo "$TARGET $MODE $(date +"%Y-%m-%d %H:%M")" 2> /dev/null >> "$LOOT_DIR/scans/tasks.txt" 2> /dev/null
    echo "metacy -t $TARGET -m $MODE --noreport $args" >> "$LOOT_DIR/scans/$OUT_FILE-$MODE.txt" 2> /dev/null
    echo "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M"))) •._.·°¯))؟•" >> "$LOOT_DIR/scans/notifications_new.txt"
    if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
      /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M"))) •._.·°¯))؟•"
    fi
    metacy -t $TARGET -m $MODE --noreport $args | tee "$LOOT_DIR/output/metacy-$MODE-$(date +"%Y%m%d%H%M").txt" 2>&1
    exit
  fi

  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  echo -e "$OKRED RUNNING PING DISCOVERY SCAN $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  nmap -n -sP $TARGET | tee "$LOOT_DIR/ips/metacy-$OUT_FILE-ping.txt"
  cat "$LOOT_DIR/ips/metacy-$OUT_FILE-ping.txt" 2> /dev/null | grep "scan report" | awk '{print $5}' > "$LOOT_DIR/ips/metacy-$OUT_FILE-ping-sorted.txt"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  echo -e "$OKRED RUNNING TCP PORT SCAN $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  nmap -n -v -p $QUICK_PORTS $NMAP_OPTIONS -sS $TARGET -Pn 2> /dev/null | grep "open port" | tee "$LOOT_DIR/ips/metacy-$OUT_FILE-tcp.txt" 2>/dev/null
  cat "$LOOT_DIR/ips/metacy-$OUT_FILE-tcp.txt" | grep open | grep on | awk '{print $6}' > "$LOOT_DIR/ips/metacy-$OUT_FILE-tcpips.txt"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  echo -e "$OKRED RUNNING UDP PORT SCAN $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  nmap -n -v -p $DEFAULT_UDP_PORTS $NMAP_OPTIONS -sU -Pn $TARGET 2> /dev/null | grep "open port" | tee "$LOOT_DIR/ips/metacy-$OUT_FILE-udp.txt" 2>/dev/null
  cat "$LOOT_DIR/ips/metacy-$OUT_FILE-udp.txt" | grep open | grep on | awk '{print $6}' > "$LOOT_DIR/ips/metacy-$OUT_FILE-udpips.txt"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  echo -e "$OKRED CURRENT TARGETS $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  cat "$LOOT_DIR/ips/metacy-$OUT_FILE-ping-sorted.txt" "$LOOT_DIR/ips/metacy-$OUT_FILE-tcpips.txt" "$LOOT_DIR/ips/metacy-$OUT_FILE-udpips.txt" 2> /dev/null > "$LOOT_DIR/ips/metacy-$OUT_FILE-ips-unsorted.txt"
  sort -u "$LOOT_DIR/ips/metacy-$OUT_FILE-ips-unsorted.txt" > "$LOOT_DIR/ips/discover-$OUT_FILE-sorted.txt"
  cat "$LOOT_DIR/ips/discover-$OUT_FILE-sorted.txt"
  echo ""
  echo -e "$OKRED[+]$RESET Target list saved to $LOOT_DIR/ips/discover-$OUT_FILE-sorted.txt"
  echo -e "$OKRED[i] To scan all IPs, use metacy -f $LOOT_DIR/ips/discover-$OUT_FILE-sorted.txt -m flyover -w $WORKSPACE $RESET"
  source "$INSTALL_DIR/modes/sc0pe.sh"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  echo -e "$OKRED SCAN COMPLETE! $RESET"
  echo -e "${OKGREEN}====================================================================================${RESET}•x${OKGREEN}[$(date +"%Y-%m-%d %H:%M")]${RESET}x•"
  echo "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M"))) •._.·°¯))؟•" >> "$LOOT_DIR/scans/notifications_new.txt"
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M"))) •._.·°¯))؟•"
  fi
  metacy -f "$LOOT_DIR/ips/discover-$OUT_FILE-sorted.txt" -m flyover -w $WORKSPACE
  exit
fi
