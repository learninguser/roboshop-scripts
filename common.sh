status_check(){
    if[ $? -eq 0 ]; then
        echo -e "\e[32mSuccess\e[0m"
    else
        echo -e "\e[31mFailure\e[0m"
        echo "Refer Log file ($1) for more information, "
        exit 1
    fi
}

print_message(){
    echo -e "\e[1;35m$1\e[0m"
}