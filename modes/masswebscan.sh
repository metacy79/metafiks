# MASSWEB MODE #####################################################################################################
if [[ "$MODE" = "masswebscan" ]]; then
  if [[ -z "$FILE" ]]; then
    logo
    echo "You need to specify a list of targets (ie. -f <targets.txt>) to scan."
    exit
  fi
  
  if [[ "$REPORT" = "1" ]]; then
    while IFS= read -r a; do
      if [[ ! -z "$WORKSPACE" ]]; then
        args="$args -w $WORKSPACE"
        WORKSPACE_DIR=$INSTALL_DIR/loot/workspace/$WORKSPACE
        echo -e "$OKBLUE[*]$RESET Saving loot to $LOOT_DIR [$RESET${OKGREEN}OK${RESET}$OKBLUE]$RESET"
        mkdir -p $WORKSPACE_DIR/domains $WORKSPACE_DIR/screenshots $WORKSPACE_DIR/nmap $WORKSPACE_DIR/notes $WORKSPACE_DIR/reports $WORKSPACE_DIR/output $WORKSPACE_DIR/vulnerabilities $WORKSPACE_DIR/scans 2> /dev/null
      fi
      args="$args -m webscan --noreport --noloot"
      TARGET="$a"
      args="$args -t $TARGET"
      TIMESTAMP=$(date +"%Y%m%d%H%M")
      if [[ ! -z "$WORKSPACE_DIR" ]]; then
        echo "metacy -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/$TARGET-$MODE.txt
        echo "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications_new.txt
        if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
          /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
        fi
        metacy $args | tee $WORKSPACE_DIR/output/metacy-$TARGET-$MODE-$TIMESTAMP.txt 2>&1
      else
        echo "metacy -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/$TARGET-$MODE.txt
        metacy $args | tee $LOOT_DIR/output/metacy-$TARGET-$MODE-$TIMESTAMP.txt 2>&1
      fi
      args=""
    done < "$FILE"
  fi

  echo "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications_new.txt
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] (`date +"%Y-%m-%d %H:%M"`) •._.·°¯))؟•"
  fi
  
  if [[ "$LOOT" = "1" ]]; then
    loot
  fi
  
  exit
fi

