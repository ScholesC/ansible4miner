#!/usr/bin/python
#
#
#
import os,sys,commands

def help():
  print "Usage:  "
  print "       %s process_name [process_port]"%sys.argv[0]
  print "Example: "
  print "       %s mysql         ;If the process_nameexists, output 1, otherwise 0"%sys.argv[0]
  print "       %s nginx  80     ;If the process_port exists, output 1,otherwise 0"%sys.argv[0]
  print "       %s mysql  3306 "%sys.argv[0]

def check_process_name():
  process_num=commands.getstatusoutput("pgrep %s|wc -l "%(sys.argv[1]))
  if not process_num[1]:
    print "0"
    return
  if int(process_num[1]) >= 1:
    print "1"
  else:
    print "0"


def check_process_port():
    process_num=commands.getstatusoutput("netstat -lnt|grep -v grep|grep ':%s '|wc -l"%sys.argv[2])
    if int(process_num[1]) >=1:
      print "1"
    else:
      print "0"

###start execute
if len(sys.argv) == 2:
    check_process_name()
    sys.exit()
elif len(sys.argv) == 3:
    check_process_port()
    sys.exit()
else:
    help()
    sys.exit()

