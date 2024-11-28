# ECS FargateでFireLensを利用している場合、Firelensが自動で立ち上げるlog routerコンテナにログがリアルタイムに渡されずバッファリングされます。
# これはそのための対応です。
# 以下に似た問題がissueに上がっています。
# https://github.com/aws/aws-sdk-rails/issues/112
STDOUT.sync = true
STDERR.sync = true
