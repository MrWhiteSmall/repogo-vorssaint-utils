#!/bin/bash
set -eu
check_only=0
if [ "${1:-}" = "--check" ]; then check_only=1; shift; fi
app_path="${1:-/Applications/Vorssaint.app}"
official_url='https://github.com/vorssaint/vorssaint-utils/releases/tag/v3.4.3'
if [ "$(uname -s)" != Darwin ] || [ "$(uname -m)" != arm64 ]; then
  echo '此官方应用要求 Apple Silicon Mac；Windows、Linux 和 Intel Mac 不适用。' >&2
  exit 2
fi
major="$(sw_vers -productVersion | cut -d. -f1)"
if [ "$major" -lt 14 ]; then echo '需要 macOS 14 或更新版本。' >&2; exit 2; fi
if [ ! -d "$app_path/Contents" ]; then
  echo "未找到已安装应用：$app_path"
  echo "请先从官方发布页下载安装：$official_url"
  echo '安装后运行：bash start.command /Applications/Vorssaint.app'
  exit 3
fi
bundle_id="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$app_path/Contents/Info.plist")"
if [ "$bundle_id" != 'com.vorssaint.utils' ]; then echo '不是预期的官方应用身份，停止。' >&2; exit 4; fi
/usr/bin/codesign --verify --deep --strict "$app_path"
details="$(/usr/bin/codesign -d --verbose=4 "$app_path" 2>&1)"
if ! echo "$details" | /usr/bin/grep -q '^TeamIdentifier=3D485NHW29$'; then
  echo '签名团队与本期核验的官方团队不一致，停止并核对原作者来源。' >&2; exit 4
fi
/usr/sbin/spctl --assess --type execute "$app_path"
version="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$app_path/Contents/Info.plist")"
echo "官方身份与系统安全检查通过，应用版本：$version"
if [ "$version" != '3.4.3' ]; then echo '注意：本期实测为3.4.3，当前版本未在本期资料中验证。'; fi
if [ "$check_only" -eq 1 ]; then exit 0; fi
/usr/bin/open "$app_path"
echo '请从菜单栏进入 设置 → 草稿板；关闭浮窗不等于退出应用。'
