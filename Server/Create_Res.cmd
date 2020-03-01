del XClient.RES

echo NOTIFY WAV notify.wav >> XClient.rc
echo NOTIFYOFF WAV NotifyOff.wav >> XClient.rc

brcc32.exe XClient.rc

del XClient.rc
pause