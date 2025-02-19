# init
# nc --recv-only -l 8123 | tar -xzC .

function send_file() {
  local usage="usage: send_file [-s server_address] [-p port] [-v] <files or directories>"
  local server="-l"
  local port=8123
  local verbose=''
  while getopts "s:p:hv" arg; do
    case $arg in
    s) server="${OPTARG}" ;;
    p) port="${OPTARG}" ;;
    v) verbose='-v' ;;
    h | ?)
      echo $usage
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # $@ is the files, $# is count of the files
  if [ $# -eq 0 ]; then
    echo $usage
    return 1
  else
    tar -czf ${verbose} - ${@} | nc ${server} ${port}
    return $?
  fi
}

function recv_file() {
  local usage="usage: recv_file [-s server_address] [-p port] [-v] [-d save directory]"
  local server="-l"
  local directory='.'
  local port=8123
  local verbose=''
  while getopts "d:s:p:hv" arg; do
    case $arg in
    s) server="${OPTARG}" ;;
    p) port="${OPTARG}" ;;
    d) directory="${OPTARG}" ;;
    v) verbose='-v' ;;
    h | ?)
      echo $usage
      return 1
      ;;
    esac
  done

  if [ $(uname) = 'Darwin' ]; then
    nc -d ${server} ${port} | tar -xzC ${verbose} ${directory}
  else
    nc --recv-only ${server} ${port} | tar -xzC ${verbose} ${directory}
  fi
  return $?
}

alias rf=recv_file
alias sf=send_file
