# MASSWEB MODE #####################################################################################################
if [[ "$MODE" = "massweb" ]]; then
  if [[ -z "$FILE" ]]; then
    logo
    echo "You need to specify a list of targets (ie. -f <targets.txt>) to scan."
    exit
  fi

  if [[ "$REPORT" = "1" ]]; then
    for a in $(cat "$FILE"); do
      if [[ -n "$WORKSPACE" ]]; then
        args="$args -w $WORKSPACE"
        WORKSPACE_DIR="$INSTALL_DIR/loot/workspace/$WORKSPACE"
        echo -e "$OKBLUE[*]$RESET Saving loot to $LOOT_DIR [$RESET${OKGREEN}OK${RESET}$OKBLUE]$RESET"
        mkdir -p "$WORKSPACE_DIR/domains" "$WORKSPACE_DIR/screenshots" "$WORKSPACE_DIR/nmap" "$WORKSPACE_DIR/notes" "$WORKSPACE_DIR/reports" "$WORKSPACE_DIR/output" 2> /dev/null
      fi
      args="$args -m web --noreport --noloot"
      TARGET="$a"
      echo "__________________________________________________________"
      echo -e "$RESET"

      if [[ -n "$WORKSPACE_DIR" ]]; then
        echo "metacy -t $TARGET -m $MODE --noreport $args" >> "$LOOT_DIR/scans/$TARGET-$MODE.txt"
        echo "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M")) •._.·°¯))؟•" >> "$LOOT_DIR/scans/notifications_new.txt"

        if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
          /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M")) •._.·°¯))؟•"
        fi
        metacy $args | tee "$WORKSPACE_DIR/output/metacy-$TARGET-$MODE-$(date +"%Y%m%d%H%M").txt" 2>&1
      else
        echo "metacy -t $TARGET -m $MODE --noreport $args" >> "$LOOT_DIR/scans/$TARGET-$MODE.txt"
        metacy $args | tee "$LOOT_DIR/output/metacy-$TARGET-$MODE-$(date +"%Y%m%d%H%M").txt" 2>&1
      fi

      args=""
    done
  fi

  echo "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M")) •._.·°¯))؟•" >> "$LOOT_DIR/scans/notifications_new.txt"

  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M")) •._.·°¯))؟•"
  fi

  if [[ "$LOOT" = "1" ]]; then
    loot
  fi

  exit
fi
