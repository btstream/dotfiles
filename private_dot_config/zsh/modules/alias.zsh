alias more="bat"
alias youtube-dl="youtube-dl -f \
'bestvideo[ext=mp4,height<=720]+bestaudio[ext=m4a]/\
bestvideo[ext=mp4,height<=480]+bestaudio[ext=m4a]/\
best[ext=mp4,height<=480]/best' --proxy http://127.0.0.1:1081 \
--external-downloader aria2c --external-downloader-args '-x 10'"
