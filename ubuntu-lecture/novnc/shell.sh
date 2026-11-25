case ":$PATH:" in
    *:/opt/venv/bin:*) ;;
    *) PATH=/opt/venv/bin:$PATH; export PATH ;;
esac
case $- in
    *i*) [ "$PWD" != / ] || cd ;;
esac