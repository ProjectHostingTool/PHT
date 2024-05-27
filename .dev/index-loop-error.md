This bash code has bug as can't indexing last line of $conf_file var value.

```bash
while IFS='=' read -r key value
do
    if [[ -z "${key}" || ${key:0:1} == "#" ]]; then
        continue
    fi

    case "$key" in
        "os") os="$value" ;;
        "giturl") giturl="$value" ;;
        "exec") exec="$value" ;;
        "vpath") vpath="$value" ;;
        *) warnlog "Unknown key found: $key" ;;
    esac
done < "$conf_file"
```