#!/bin/bash

# ---------------------------------------------------------------------------
# 概要:
#   developからリリースブランチ作成後、mainへのマージのプルリクを作成します。
#
# 使用方法:
#   ./create_release.sh [major|minor|patch|]
#   例: ./create_release.sh major
#
# 注意点:
#   - GitHub CLIのインストールが必要です。
#   - mainへのマージのプルリクはMerge Pull request(Create a merge commit)でマージしてください。
# ---------------------------------------------------------------------------

set -e

if [ -z "$1" ] || [[ ! "$1" =~ ^(major|minor|patch)$ ]]; then
  echo "バージョンをインクリメントするタイプを指定してください。"
  echo "使用可能なオプション: major, minor, patch"
  exit 1
fi

# `gh` コマンドの存在確認
if ! command -v gh >/dev/null 2>&1; then
  echo "'gh' コマンドが見つかりません。GitHub CLIをインストールしてください。"
  exit 1
fi

git fetch --tags
git fetch origin main

# main ブランチから最新のタグを取得
latest_tag=$(git describe --tags --abbrev=0 origin/main 2>/dev/null || true)

# タグが存在しない場合はデフォルトの0.0.0とする
if [ -z "${latest_tag}" ]; then
  new_version="v0.0.0"
else
  # バージョン番号を分割
  major=$(echo ${latest_tag} | cut -d'.' -f1 | tr -d 'v')
  minor=$(echo ${latest_tag} | cut -d'.' -f2)
  patch=$(echo ${latest_tag} | cut -d'.' -f3)

  # 引数に応じてバージョンをインクリメント
  case $1 in
    "major")
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    "minor")
      minor=$((minor + 1))
      patch=0
      ;;
    "patch")
      patch=$((patch + 1))
      ;;
  esac

  new_version="v${major}.${minor}.${patch}"
fi

new_branch="release/${new_version}"

echo "現在のバージョン: ${latest_tag}"
echo "新しいバージョン: ${new_version}"
echo "リリースブランチ ${new_branch} を作成します。よろしいですか? (y/n) "
read confirmation

case ${confirmation} in
  [Yy]* )
    # リモートリポジトリのブランチ一覧を取得
    remote_branches=$(git ls-remote --heads origin)

    # 該当バージョン番号を含むブランチが存在するか確認
    matching_branches=$(echo "${remote_branches}" | grep "${new_version}" || true)

    if [[ ! -z "${matching_branches}" ]]; then
      echo "リモートリポジトリのブランチ名で${new_version}と部分一致するものが存在します。"
      echo "リリース済みの場合はmainブランチにリリースを作成、未リリースの場合はブランチ名に含まれるバージョン番号を適切なものに変更してください。"
      echo "${matching_branches}"
      exit 1
    fi

    git checkout develop
    git pull

    git checkout -b ${new_branch}
    git push -u origin ${new_branch}
    echo "リリースブランチ ${new_branch} をリモートにpushしました。"

    # ログの差分を取得
    log_diff=$(git log origin/main..origin/develop --pretty=format:"%h - %s (%an, %ad)")

    # プルリク作成
    gh pr create --base main --head "${new_branch}" --title "Merge ${new_branch} into main" --body "${log_diff}" --web

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
