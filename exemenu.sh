#!/bin/bash
######################################################################################
#
# 実行メニュー
# 機能概要：GUIメニュー形式のコマンド実行ツール（内容は設定ファイルを読込む）
#
######################################################################################

HOST_NAME=`hostname`
AWK=/usr/bin/awk
CONF_FILE="./template_exemenu.conf"

MEIN_MENU()
{
while :
do
  clear
  echo ""
  echo "###################################"
  echo "# MENU"
  echo "# Host Name: ${HOST_NAME}"
  echo "# Menu Name: ${MENU_NAME}"
  echo "###################################"
  echo "-----------------------------------"
  echo " 番号 | 操作"
  echo "-----------------------------------"

  for (( i=1; i<${MEIN_COUNT}; i++))
  {
    #-- タイトル生成 --"
    CREATE_TITLE="TITLE_${i}" 
    echo "    ${i} | ${!CREATE_TITLE}"
    echo "-----------------------------------"
  }

  echo "    0 | exit"
  echo "-----------------------------------"

  echo ""
  echo -n "番号を入力して下さい : "
  read USER_ANSWER
  USER_ANSWER=`echo ${USER_ANSWER}`

  if [ -z "${USER_ANSWER}" ]
  then
     echo "番号が入力されていません"
     RETURN_ENTER
     continue
  fi

  if [ `echo ${USER_ANSWER} | wc -w` -ne 1 ]
  then
     echo "番号を一つだけ入力して下さい"
     RETURN_ENTER
     continue
  fi

  USER_ANSWER=`echo ${USER_ANSWER} | grep "^[0-9]*$"`
  if [ -z "${USER_ANSWER}" ]
  then
     echo "有効な番号を入力して下さい"
     RETURN_ENTER
     continue
  fi

  #-- 入力番号チェック --#
  if [ "0" -lt "${USER_ANSWER}" -a "${USER_ANSWER}" -lt "${MEIN_COUNT}" ]; then

    #-- 実行コマンド生成 --#
    CREATE_EXE="EXE_${USER_ANSWER}" 

    if [[ "${!CREATE_EXE}" = "SUB_MENU" ]]; then
      #-- サブメニュー起動 --#
      SUB_MENU "${USER_ANSWER}"
      continue
    else
      #-- コマンド実行前確認 --#
      SEPARATION
      COMMAND_CHECK "${!CREATE_EXE}"
      if [ "$?" -eq "1" ]; then
        #-- コマンド実行 --#
        ${!CREATE_EXE}
      fi
      RETURN_ENTER
    fi

  fi

  #-- 入力番号チェック --#
  case "${USER_ANSWER}" in
      0)
         break
         ;;
      *)
         echo "有効な番号を入力して下さい"
         ;;
      esac
  done
}

RETURN_ENTER(){
  SEPARATION
  echo -n "Enterを入力して下さい : "
  read ENTER
}

COMMAND_CHECK(){
  EXE_COMMAND="$1"
  while :
  do
    echo "コマンド -> ${EXE_COMMAND}"
    echo -n "実行しますか？(y or n) -> "
    read YorN
    SEPARATION
    YorN=`echo "${YorN}" | tr "yes" "YES" | tr "no" "NO"`
    if [ "${YorN}" = 'Y' -o "${YorN}" = 'YES' ]; then
      return 1
    elif [ "${YorN}" = 'N' -o "${YorN}" = 'NO' ]; then
      echo "実行を中止しました"
      return 0
    fi
  done 
}

SEPARATION(){
  echo "-----------------------------------"
}

SUB_MENU(){
  CREATE_TITLE="TITLE_$1" 
  SUB_MENU_NUMBER="$1"
  SUB_COUNT=1

  #-- サブメニュー項目数を8までに制御 --#
  #-- 増やすと動作が重くなる          --#
  for (( i=1; i<9; i++))
  {
    CREATE_SUB_TITLE="TITLE_${SUB_MENU_NUMBER}_${i}" 
    if [[ "${!CREATE_SUB_TITLE}" = "" ]]; then
      break
    fi

    SUB_COUNT=`expr ${SUB_COUNT} + 1`
  }

  while :
  do
    clear
    echo ""
    echo "###################################"
    echo "# SUB MENU"
    echo "# Host Name: ${HOST_NAME}"
    echo "# Sub  Name: ${!CREATE_TITLE}"
    echo "###################################"
    echo "-----------------------------------"
    echo " 番号 | 操作"
    echo "-----------------------------------"
  
    for (( i=1; i<${SUB_COUNT}; i++))
    {
      #-- タイトル生成 --"
      CREATE_SUB_TITLE="TITLE_${SUB_MENU_NUMBER}_${i}" 
      echo "    ${i} | ${!CREATE_SUB_TITLE}"
      echo "-----------------------------------"
    }
  
    echo "    0 | back"
    echo "-----------------------------------"
  
    echo ""
    echo -n "番号を入力して下さい : "
    read USER_ANSWER
    USER_ANSWER=`echo ${USER_ANSWER}`
  
    if [ -z "${USER_ANSWER}" ]
    then
       echo "番号が入力されていません"
       RETURN_ENTER
       continue
    fi
  
    if [ `echo ${USER_ANSWER} | wc -w` -ne 1 ]
    then
       echo "番号を一つだけ入力して下さい"
       RETURN_ENTER
       continue
    fi
  
    USER_ANSWER=`echo ${USER_ANSWER} | grep "^[0-8]$"`
    if [ -z "${USER_ANSWER}" ]
    then
       echo "有効な番号を入力して下さい"
       RETURN_ENTER
       continue
    fi
  
    if [ "0" -lt "${USER_ANSWER}" -a "${USER_ANSWER}" -lt "${SUB_COUNT}" ]; then
  
      #-- 実行コマンド生成 --#
      CREATE_EXE="EXE_${SUB_MENU_NUMBER}_${USER_ANSWER}" 

      #-- コマンド実行前確認 --#
      SEPARATION
      COMMAND_CHECK "${!CREATE_EXE}"
      if [ "$?" -eq "1" ]; then
        #-- コマンド実行 --#
        ${!CREATE_EXE}
      fi
      RETURN_ENTER
  
    fi
  
    case "${USER_ANSWER}" in
        0)
           break
           ;;
        *)
           echo "有効な番号を入力して下さい"
           ;;
        esac
  done
}


CONF_INPUT(){
  #----------------------#
  # 設定ファイルの読込み #
  #----------------------#
  
  #-- メインメニューカウンタ --#
  MEIN_COUNT=1

  #-- サブメニューカウンタ初期化 --#
  j=0

  while read line
  do
    #-- 先頭が"#"の行はスキップ --#
    if [ `echo $line | cut -c1` == "#" ]; then
      continue
    fi
 
    #-- 先頭が"<"の場合はメニュー名取得 --#
    if [ `echo $line | cut -c1` == ":" ]; then
      MENU_NAME=`echo $line | sed -e 's/^[:MENU_NAME:]*//'`
      continue
    fi
  
    #-- 設定ファイル１行を"|"パイプで分割 --#
    TITLE=`echo $line | ${AWK} 'BEGIN { FS = "|"; } { print $1 }'`
    EXE=`echo $line | ${AWK} 'BEGIN { FS = "|"; } { print $2 }'`
  
    #-- 行頭のホワイトスペースを削除 --#
    TITLE=`echo ${TITLE} | sed -e 's/^[ 	　]*//g'`
    EXE=`echo ${EXE} | sed -e 's/^[ 	　]*//g'`
  
    #-- 行末のホワイトスペースを削除 --#
    TITLE=`echo ${TITLE} | sed -e 's/[ 	　]*$//g'`
    EXE=`echo ${EXE} | sed -e 's/[ 	　]*$//g'`
  
    case "$TITLE" in
      ──*)
        #-- サブメニューカウンタチェック処理 --#
        if [[ "$j" -ne "0" ]]; then
          echo "設定ファイルの記入が誤っています"
          exit 1
        fi
  
        #-- 項目名先頭の判別文字を削除 --# 
        TITLE=`echo ${TITLE} | sed -e 's/^[──]*//'`

        if [[ "$EXE" = "[drilldown]" ]]; then
          #-- サブメニューカウンタ --#
          j=1

          #-- 動的変数へ保存 --#
          eval 'TITLE_'${MEIN_COUNT}='${TITLE}'
          eval 'EXE_'${MEIN_COUNT}="SUB_MENU"
  
        else
          #-- サブメニューカウンタチェック処理 --#
          if [[ "$j" -ne "0" ]]; then
            echo "設定ファイルの記入が誤っています"
            exit 1
          fi
  
          #-- 動的変数へ保存 --#
          eval 'TITLE_'${MEIN_COUNT}='${TITLE}'
          eval 'EXE_'${MEIN_COUNT}='${EXE}'
  
          #-- カウントＵＰ --#
          MEIN_COUNT=`expr ${MEIN_COUNT} + 1`
  
        fi
        ;;
  
      ├─*)
        #-- サブメニューカウンタチェック処理 --#
        if [ "0" -eq "${j}" -o "8" -lt "${j}" ]; then
          echo "設定ファイルの記入が誤っています"
          exit 1
        fi

        #-- 項目名先頭の判別文字を削除 --# 
        TITLE=`echo ${TITLE} | sed -e 's/^[├─]*//'`

        #-- 動的変数へ保存 --#
        eval 'TITLE_'${MEIN_COUNT}'_'${j}='${TITLE}'
        eval 'EXE_'${MEIN_COUNT}'_'${j}='${EXE}'
  
        #-- カウントＵＰ --#
        j=`expr ${j} + 1`
  
        ;;
  
      └─*)
         #-- サブメニューカウンタチェック処理 --#
        if [ "0" -eq "${j}" -o "8" -lt "${j}" ]; then
          echo "設定ファイルの記入が誤っています"
          exit 1
        fi
  
        #-- 項目名先頭の判別文字を削除 --# 
        TITLE=`echo ${TITLE} | sed -e 's/^[└─]*//'`

        #-- 動的変数へ保存 --#
        eval 'TITLE_'${MEIN_COUNT}'_'${j}='${TITLE}'
        eval 'EXE_'${MEIN_COUNT}'_'${j}='${EXE}'
  
        #-- カウントＵＰ --#
        MEIN_COUNT=`expr ${MEIN_COUNT} + 1`
  
        #-- サブメニューカウンタ初期化 --#
        j=0
  
        ;;
  
       *)
        echo "設定ファイルの記入が誤っています"
        exit 1
        ;;
     esac
  
  done < ${CONF_FILE}
}

#### Main ####

# 設定ファイルの読込み
CONF_INPUT

# メインメニュー表示
MEIN_MENU

