echo "---" | tee -a /tmp/polybar1.log /tmp/polybar2.log
polybar mainbar 2>&1 | tee -a /tmp/polybar1.log &
disown
polybar sidebar1 2>&1 | tee -a /tmp/polybar2.log &
disown
echo "Bars launched..."
