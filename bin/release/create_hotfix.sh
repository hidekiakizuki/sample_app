#!/bin/bash

# ---------------------------------------------------------------------------
# 概要:
#   mainからhotfix作成後、mainへのマージのプルリクを作成します。
#
# 使用方法:
#   ./create_hotfix.sh
#   例: ./create_hotfix.sh
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

git fetch --tags
git fetch origin main

# main ブランチから最新のタグを取得
latest_tag=$(git describe --tags --abbrev=0 origin/main 2>/dev/null || true)

if [ -z "${latest_tag}" ]; then
  echo "mainブランチにタグが見つかりません。"
  exit 1
fi

# バージョン番号をセット
major=$(echo ${latest_tag} | cut -d'.' -f1 | tr -d 'v')
minor=$(echo ${latest_tag} | cut -d'.' -f2)
patch=$(echo ${latest_tag} | cut -d'.' -f3)
patch=$((patch + 1))

new_version="v${major}.${minor}.${patch}"

# リモートリポジトリのブランチ一覧を取得
remote_branches=$(git ls-remote --heads origin | awk -F'/' '{print $NF}')

# 該当バージョン番号を含むブランチが存在するか確認
matching_branches=$(echo "$remote_branches" | grep "$new_version")

if [[ ! -z "${matching_branches}" ]]; then
  echo "リモートリポジトリのブランチ名で${new_version}と部分一致するものが存在します。"
  ehoc "ブランチ名に含まれるバージョン番号を適切なものに変更してください。"
  echo "${matching_branches}"
  exit 1
fi

new_branch="hotfix/${new_version}"

echo "現在のバージョン: ${latest_tag}"
echo "新しいバージョン: ${new_version}"
read -p "hotfixブランチ ${new_branch} を作成します。よろしいですか? (y/n)" confirmation

case ${confirmation} in
  [Yy]* )
    git checkout main
    git pull

    git checkout -b ${new_branch}
    git push -u origin ${new_branch}
    echo "hotfixブランチ ${new_branch} をリモートにpushしました。"

    # プルリク作成
    gh pr create --base main --head "${new_branch}" --title "Merge ${new_branch} into main" --web

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
