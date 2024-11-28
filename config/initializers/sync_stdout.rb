# frozen_string_literal: true

# ECS FargateでFireLensを利用しているコンテナでworkerを起動すると、
# Firelensが自動で立ち上げるlog routerコンテナにログがリアルタイムに渡されずバッファリングされます。
# これはそのための対応です。
# 以下に似た問題がissueに上がっています。
# https://github.com/aws/aws-sdk-rails/issues/112
if ENV['ENABLE_SYNC_STDOUT'].present?
  $stdout.sync = true
  $stderr.sync = true
end
