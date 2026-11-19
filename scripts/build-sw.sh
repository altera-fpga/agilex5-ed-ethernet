#!/bin/bash
set -e
set -x
umask 022

echo "FLAG_DIR: $FLAG_DIR"

# VARIANT selects the design (default mk-a5e065bb32aea/ethernet); sets ETH_DIR, REVISION
. "$(dirname "$0")/variant_config.sh"
echo "VARIANT: $VARIANT"

ETH_ROOT="$ETH_DIR"
YOCTO_DIR="$ETH_ROOT/software/yocto_linux"
RBF_DEST="$YOCTO_DIR/meta-custom/recipes-fpga/fpga-bitstream/files"
# Must match ETH_DESIGN → FPGA_RBF_FILE in <design>/software/yocto_linux/meta-custom/conf/eth-solution.inc
RBF_NAME="${REVISION}.core.rbf"
# DEPLOY_DIR set after YOCTO_TMPDIR (deploy lives under BitBake TMPDIR)

if [ -z "${FLAG_DIR:-}" ]; then
  echo "ERROR: FLAG_DIR must point to a hardware build's build_flags directory." >&2
  exit 1
fi
if [ ! -d "$FLAG_DIR" ]; then
  echo "ERROR: FLAG_DIR does not exist: $FLAG_DIR" >&2
  exit 1
fi
FLAG_DIR="$(cd "$FLAG_DIR" && pwd)"

# Hybrid layout (required by OE + ARC):
# - Sources / sstate under BUILD_ROOT — survives node issues, shared sstate
# - BitBake TMPDIR on node-local disk
if [ -n "${BUILD_ROOT:-}" ]; then
  WORKDIR="${BUILD_ROOT}/.yocto-build"
  echo "Using BUILD_ROOT workdir: $WORKDIR"
  mkdir -vp "$WORKDIR"
elif [ -d "$ETH_ROOT/software/yocto_linux" ]; then
  WORKDIR="$(pwd)"
  echo "Using ARC iwd as workdir: $WORKDIR"
else
  WORKDIR=$(mktemp -d)
  echo "WARNING: falling back to /tmp workdir: $WORKDIR"
  trap 'rm -rf "$WORKDIR"' EXIT
fi

# Node-local TMPDIR (ARC class requests tfds scratch under /tmp)
if [ -z "${YOCTO_TMPDIR:-}" ]; then
  if [ -n "${BUILD_ROOT:-}" ]; then
    YOCTO_TMPDIR="/tmp/yocto-tmp-$(basename "$BUILD_ROOT")"
  else
    YOCTO_TMPDIR="/tmp/yocto-tmp-$$"
  fi
fi
mkdir -vp "$YOCTO_TMPDIR"
export YOCTO_TMPDIR
echo "YOCTO_TMPDIR (node-local BitBake TMPDIR)=$YOCTO_TMPDIR"
df -h "$YOCTO_TMPDIR" /tmp 2>/dev/null || df -h /tmp || true
# Clean only local tmp on exit; keep build sources for debug
trap 'rm -rf "$YOCTO_TMPDIR"' EXIT

cd "$WORKDIR"
echo "Build branch: $GITHUB_REF"
echo "Resolved FLAG_DIR=$FLAG_DIR"

# Fresh tip checkout into WORKDIR (rsync'd iwd has no .git).
# Creds must exist before fetch: the design repo is private, and the kas
# gitconfig below is written only after this checkout.
set +x
python3 - <<'PY'
import os
from pathlib import Path
token = os.environ.get("GITHUB_TOKEN", "")
user = os.environ.get("GITHUB_USER") or "x-access-token"
if not token:
    raise SystemExit("ERROR: GITHUB_TOKEN is unset in ARC env.")
cfg = Path("/tmp/ci-gitconfig")
cfg.write_text(
    '[url "https://%s:%s@github.com/"]\n'
    "\tinsteadOf = https://github.com/\n"
    "\tinsteadOf = git://github.com/\n" % (user, token)
)
cfg.chmod(0o600)
print("Configured private GitHub fetch for user=%s" % user)
PY
export GIT_CONFIG_GLOBAL=/tmp/ci-gitconfig
set -x
if [ ! -d .git ]; then
  git init
  git remote add origin "$GITHUB_SERVER_URL"/"$GITHUB_REPOSITORY"
fi
git fetch origin "$GITHUB_REF"
git checkout -f FETCH_HEAD

mkdir -vp "$RBF_DEST"
if [ -n "$SSTATE_DIR" ]; then
  mkdir -vp "$SSTATE_DIR"
  ln -vsnfT "$SSTATE_DIR" "$YOCTO_DIR/sstate_cache" || true
fi

HW_FLAG="$FLAG_DIR/hardware_done"

if [[ -f "$HW_FLAG" ]]; then
  echo "Hardware build is completed ($FLAG_DIR)."
  ls -lrt "$FLAG_DIR"/../hw/*core.rbf
  cp -f "$FLAG_DIR"/../hw/*core.rbf "$RBF_DEST/$RBF_NAME"
  sha1sum "$FLAG_DIR"/../hw/*core.rbf
  sha1sum "$RBF_DEST/$RBF_NAME"
else
  echo "ERROR: No hardware_done at $FLAG_DIR"
  echo "SW needs HW to publish *core.rbf + build_flags/hardware_done"
  ls -la "$FLAG_DIR" 2>/dev/null || true
  ls -la "$(dirname "$FLAG_DIR")/hw" 2>/dev/null || true
  exit 1
fi

# kas needs creds for private meta-altera-fpga. Prefer .netrc (kas NETRC_FILE)
# plus insteadOf — URL-in-gitconfig alone is sometimes ignored in kas's temp HOME.
set +x
if [ -z "${GITHUB_TOKEN:-}" ]; then
  echo "ERROR: GITHUB_TOKEN is unset in ARC env."
  echo "Set secrets GSRD_GITHUB_USER + GSRD_GITHUB_PAT, push workflows, NEW workflow run."
  set -x
  exit 1
fi
GITHUB_USER="${GITHUB_USER:-x-access-token}"
GITCFG="$YOCTO_DIR/.gitconfig"
NETRC="$YOCTO_DIR/.netrc"
# Cover https and git:// (bitbake uses git://...;protocol=https for linux-socfpga)
cat > "$GITCFG" <<EOF
[url "https://${GITHUB_USER}:${GITHUB_TOKEN}@github.com/"]
	insteadOf = https://github.com/
	insteadOf = git://github.com/
[credential]
	helper =
EOF
cat > "$NETRC" <<EOF
machine github.com
login ${GITHUB_USER}
password ${GITHUB_TOKEN}
EOF
chmod 600 "$NETRC"
# BitBake do_fetch may not use kas NETRC_FILE; also install into HOME
cp -f "$GITCFG" "$HOME/.gitconfig"
cp -f "$NETRC" "$HOME/.netrc"
chmod 600 "$HOME/.netrc"
export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
echo "Wrote kas+HOME gitconfig/netrc for user=${GITHUB_USER}"
set -x

(
  cd "$YOCTO_DIR"
  export GITHUB_ACTIONS=true
  export YOCTO_TMPDIR
  export GITCONFIG_FILE="$(pwd)/.gitconfig"
  export NETRC_FILE="$(pwd)/.netrc"
  export GIT_CONFIG_GLOBAL="$HOME/.gitconfig"
  # Path must be relative to YOCTO_DIR (we already cd'd here)
  ./build.sh "meta-custom/recipes-fpga/fpga-bitstream/files/$RBF_NAME" sd
)

if [ -z "${DESTDIR:-}" ]; then
  echo "ERROR: DESTDIR is unset; cannot publish SW artifacts"
  exit 1
fi

# Deploy images live under BitBake TMPDIR (node-local when YOCTO_TMPDIR is set)
if [ -n "${YOCTO_TMPDIR:-}" ]; then
  DEPLOY_DIR="$YOCTO_TMPDIR/deploy/images/agilex5e"
else
  DEPLOY_DIR="$YOCTO_DIR/build/tmp/deploy/images/agilex5e"
fi

mkdir -vp "$DESTDIR"
echo "=== Yocto deploy images ($DEPLOY_DIR) ==="
ls -lrt "$DEPLOY_DIR" || {
  echo "ERROR: deploy dir missing: $DEPLOY_DIR"
  exit 1
}

itb_src=""
for cand in "$DEPLOY_DIR/kernel_sed.itb" "$DEPLOY_DIR/kernel.itb"; do
  if [ -f "$cand" ]; then itb_src="$cand"; break; fi
done
[ -n "$itb_src" ] || { echo "Missing ITB under $DEPLOY_DIR"; exit 1; }
# Publish both names for workflow upload compatibility
cp -f "$itb_src" "$DESTDIR/kernel_sed.itb"
cp -f "$itb_src" "$DESTDIR/kernel.itb"

console_src=""
for cand in \
  "$DEPLOY_DIR/gsrd-console-image-agilex5e.tar.gz" \
  "$DEPLOY_DIR/gsrd-console-image-agilex5e.rootfs.tar.gz" \
  "$DEPLOY_DIR/console-image-minimal-agilex5e.rootfs.tar.gz"; do
  if [ -f "$cand" ]; then console_src="$cand"; break; fi
done
[ -n "$console_src" ] || {
  echo "ERROR: No console rootfs tar.gz under $DEPLOY_DIR"
  exit 1
}
# Legacy CI artifact name expected by upload-artifact
cp -f "$console_src" "$DESTDIR/gsrd-console-image-agilex5.tar.gz"

wic=""
for cand in "$DEPLOY_DIR"/gsrd-console-image-agilex5e*.wic "$DEPLOY_DIR"/console-image-minimal-agilex5e*.wic; do
  if [ -f "$cand" ]; then wic="$cand"; break; fi
done
[ -n "$wic" ] || {
  echo "ERROR: No .wic under $DEPLOY_DIR (needed for sdimage.tar.gz)"
  exit 1
}
tar -chzf "$DESTDIR/sdimage.tar.gz" -C "$(dirname "$wic")" "$(basename "$wic")"

[ -f "$DEPLOY_DIR/u-boot-spl-dtb.hex" ] || {
  echo "ERROR: Missing u-boot-spl-dtb.hex under $DEPLOY_DIR"
  exit 1
}
cp -f "$DEPLOY_DIR/u-boot-spl-dtb.hex" "$DESTDIR/u-boot-spl-dtb.hex"

echo "=== Published to DESTDIR=$DESTDIR ==="
ls -lrt "$DESTDIR"
for req in kernel_sed.itb kernel.itb gsrd-console-image-agilex5.tar.gz sdimage.tar.gz u-boot-spl-dtb.hex; do
  [ -f "$DESTDIR/$req" ] || { echo "ERROR: missing $DESTDIR/$req"; exit 1; }
done
# Marker for workflow Copy outputs — only written after a full successful publish
touch "$DESTDIR/.sw_build_ok"
echo "Wrote $DESTDIR/.sw_build_ok"
