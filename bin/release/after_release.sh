#!/bin/bash

# ---------------------------------------------------------------------------
# 概要:
#   リリースブランチからmainへのリリース作成と、その後のdevelopへのマージのプルリクを作成します。
#
# 使用方法:
#   ./after_release.sh [release_branch名]
#   例: ./after_release.sh release/v1.0.0
#
# 注意点:
#   - GitHub CLIのインストールが必要です。
#   - リリースブランチがリモートに存在する必要があります。
#   - developへのマージのプルリクはMerge Pull request(Create a merge commit)でマージしてください。
# ---------------------------------------------------------------------------

set -e

# `gh` コマンドの存在確認
if ! command -v gh >/dev/null 2>&1; then
    echo "'gh' コマンドが見つかりません。GitHub CLIをインストールしてください。"
    exit 1
fi

# 引数で与えられたブランチ名を取得
release_branch="$1"

# ブランチ名が与えられていなければ終了
if [[ -z "${release_branch}" ]]; then
    echo "引数にリリースブランチ名を指定してください。"
    exit 1
fi

# リモートブランチの存在確認
if ! git ls-remote --heads origin "${release_branch}" | grep "${release_branch}"; then
    echo "指定されたブランチ ${release_branch} はリモートリポジトリに存在しません。"
    exit 1
fi

# ブランチ名からバージョン番号を抜き出す
version=$(echo ${release_branch} | awk -F'release/' '{print $2}')

# バージョン番号が取得できなければ終了
if [[ -z ${version} ]]; then
    echo "現在のブランチ名からバージョン番号を識別できません: ${release_branch}"
    exit 1
fi

# ユーザーにバージョン番号の確認
read -p "バージョン ${version} をmainブランチにタグ付けします。よろしいですか? (y/n) " -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "キャンセルしました。"
    exit 1
fi

gh release create ${version} --target main --generate-notes
echo "バージョン ${version} でリリースを作成しました。"

# プルリク作成
gh pr create --base develop --head "${release_branch}" --title "Merge release ${version} back into develop" --body "Merging the changes from release ${version} back into develop." --web
echo "developにマージするプルリクを作成しました。"
echo "処理が正常に終了しました。"
