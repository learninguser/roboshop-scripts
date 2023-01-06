status_check(){
    if[ $? -eq 0 ]; then
        echo -e "\e[32mSuccess\e[0m"
    else
        echo -e "\e[31mFailure\e[0m"
        echo "Refer Log file ($log_file) for more information, "
        exit 1
    fi
}