# MASSWEB MODE #####################################################################################################
if [[ "$MODE" = "massportscan" ]]; then
  if [[ -z "$FILE" ]]; then
    logo
    echo "You need to specify a list of targets (ie. -f <targets.txt>) to scan."
    exit
  fi
  if [[ "$REPORT" = "1" ]]; then
    for a in `cat $FILE`;
    do
      if [[ ! -z "$WORKSPACE" ]]; then
        args="$args -w $WORKSPACE"
        WORKSPACE_DIR=$INSTALL_DIR/loot/workspace/$WORKSPACE
        echo -e "$OKBLUE[*]$RESET Saving loot to $LOOT_DIR [$RESET${OKGREEN}OK${RESET}$OKBLUE]$RESET"
        mkdir -p $WORKSPACE_DIR 2> /dev/null
        mkdir $WORKSPACE_DIR/domains 2> /dev/null
        mkdir $WORKSPACE_DIR/screenshots 2> /dev/null
        mkdir $WORKSPACE_DIR/nmap 2> /dev/null
        mkdir $WORKSPACE_DIR/notes 2> /dev/null
        mkdir $WORKSPACE_DIR/reports 2> /dev/null
        mkdir $WORKSPACE_DIR/output 2> /dev/null
      fi
      args="$args -m fullportonly --noreport --noloot"
      TARGET="$a"
      args="$args -t $TARGET"
      echo -e "$RESET"
      if [[ ! -z "$WORKSPACE_DIR" ]]; then
        echo "$TARGET $MODE $(date +"%Y-%m-%d %H:%M")" >> $LOOT_DIR/scans/tasks.txt 2> /dev/null
        echo "metacy -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/$TARGET-$MODE.txt
        if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
          /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Started metafiks scan: $TARGET [$MODE] ($(date +'%Y-%m-%d %H:%M')) •._.·°¯))؟•"
        fi
        metacy $args | tee $WORKSPACE_DIR/output/metacy-$TARGET-$MODE-$(date +"%Y%m%d%H%M").txt 2>&1
      else
        echo "$TARGET $MODE $(date +"%Y-%m-%d %H:%M")" >> $LOOT_DIR/scans/tasks.txt 2> /dev/null
        echo "metacy -t $TARGET -m $MODE --noreport $args" >> $LOOT_DIR/scans/$TARGET-$MODE.txt
        metacy $args | tee $LOOT_DIR/output/metacy-$TARGET-$MODE-$(date +"%Y%m%d%H%M").txt 2>&1
      fi
      args=""
    done
  fi
  echo "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] ($(date +"%Y-%m-%d %H:%M")) •._.·°¯))؟•" >> $LOOT_DIR/scans/notifications_new.txt
  if [[ "$SLACK_NOTIFICATIONS" == "1" ]]; then
    /bin/bash "$INSTALL_DIR/bin/slack.sh" "[] •?((¯°·._.• Finished metafiks scan: $TARGET [$MODE] ($(date +'%Y-%m-%d %H:%M')) •._.·°¯))؟•"
  fi
  if [[ "$LOOT" = "1" ]]; then
    loot
  fi
  
  exit
fi
