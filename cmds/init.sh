for bdir in vendor/bliss_priv/proprietary vendor/bliss_priv/source; do
    if ! [ -d  ]; then
        mkdir 
    fi
done

if [ -d '/androidx86/cmds' ]; then
    rm -rf /androidx86/cmds
fi

mv cmds/setup2.sh /androidx86/vendor/bliss_priv/
mv cmds /androidx86/
