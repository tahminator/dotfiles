find . -name .git -type d -execdir sh -c '
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "No remote found")
    LOCAL_DIR=$(pwd)
    
    # Remove "https://github.com/" from REMOTE_URL if it exists
    CLEAN_REMOTE_URL=$(echo "$REMOTE_URL" | sed "s|https://github.com/||")

    echo "\033[34mRemote Repository:\033[0m \033[32m$CLEAN_REMOTE_URL\033[0m" 
    echo "\033[34mLocal Directory:\033[0m \033[32m$LOCAL_DIR\033[0m"

    git pull
    printf "\n"
' \;
