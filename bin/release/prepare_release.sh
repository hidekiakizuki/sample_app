#!/bin/bash

# ---------------------------------------------------------------------------
# 概要:
#   developからリリースブランチ作成後、mainへのマージのプルリクを作成します。
#
# 使用方法:
#   ./prepare_release.sh [major|minor|patch|]
#   例: ./prepare_release.sh major
#
# 注意点:
#   - GitHub CLIのインストールが必要です。
#   - mainへのマージのプルリクはMerge Pull request(Create a merge commit)でマージしてください。
# ---------------------------------------------------------------------------

set -e

# `gh` コマンドの存在確認
if ! command -v gh >/dev/null 2>&1; then
    echo "'gh' コマンドが見つかりません。GitHub CLIをインストールしてください。"
    exit 1
fi

git fetch origin main

# main ブランチから最新のタグを取得
latest_tag=$(git describe --tags --abbrev=0 origin/main 2>/dev/null || true)

# タグが存在しない場合はデフォルトの0.0.0とする
if [ -z "${latest_tag}" ]; then
  latest_tag="v0.0.0"
fi

# バージョン番号を分割
major=$(echo ${latest_tag} | cut -d'.' -f1 | tr -d 'v')
minor=$(echo ${latest_tag} | cut -d'.' -f2)
patch=$(echo ${latest_tag} | cut -d'.' -f3)

# 引数に応じてバージョンをインクリメント
if [ "${latest_tag}" != "v0.0.0" ]; then
  case $1 in
    "major")
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    "minor"|"")
      minor=$((minor + 1))
      patch=0
      ;;
    "patch")
      patch=$((patch + 1))
      ;;
    *)
      echo "無効な引数: $1"
      echo "正しい引数: major, minor, patch (省略時: patch)"
      exit 1
      ;;
  esac
fi

new_version="v${major}.${minor}.${patch}"
new_branch="release/${new_version}"

echo "最新のバージョン: ${latest_tag}"
echo "新しいバージョン: ${new_version}"
echo "新しいリリースブランチ $new_branch を作成します。よろしいですか? (y/n)"
read confirmation

case $confirmation in
    [Yy]* )
        git checkout develop
        git pull

        git checkout -b $new_branch
        git push -u origin $new_branch
        echo "リリースブランチ $new_branch をリモートにpushしました。"

        # ログの差分を取得
        log_diff=$(git log origin/main..origin/develop --pretty=format:"%s")

        # プルリク作成
        gh pr create --base main --head "$new_branch" --title "リリースブランチ作成: ${new_version}" --body "$log_diff" --web
        echo "プルリクを作成しました。"
        echo "処理が正常に終了しました。"
        ;;
    [Nn]* )
        echo "キャンセルしました。"
        ;;
    * )
        echo "無効な選択"
        exit 1
        ;;
esac
