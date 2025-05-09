#!/usr/bin/env bash
set -euo pipefail

# ARGS
## 1: path to this folder
## 2: file to output

# DEPENDS:
## yq
## zip

# Garunteed
export MC_VERSION="$(yq '.versions.minecraft' ./pack.toml)"
export UNSUP_VERSION="$(yq '.versions.unsup' ./pack.toml)"
# One or the other
LWJGL_VERSION="$(yq '.versions.lwjgl' ./pack.toml)"
LWJGL3_VERSION="$(yq '.versions.lwjgl3' ./pack.toml)"
# Might be ""
FORGE_VERSION="$(yq '.versions.forge' ./pack.toml)"
FABRIC_VERSION="$(yq '.versions.fabric' ./pack.toml)"

# Figure out what loader we are using
MODLOADER="vanilla"
if [[ $FORGE_VERSION != "null" ]]; then
  MODLOADER="forge"
  export FORGE_VERSION
elif [[ $FABRIC_VERSION != "null" ]]; then
  MODLOADER="fabric"
  export FABRIC_VERSION
fi

# Find lwjgl major
if [[ $LWJGL3_VERSION != "null" ]]; then
  LWJGL_MAJOR="3"
  export LWJGL3_VERSION
elif [[ $LWJGL_VERSION != "null" ]]; then
  LWJGL_MAJOR="2"
  export LWJGL_VERSION
else
  echo "Need to set an lwjgl version to use"
  exit 1
fi


# Generate agents
WORKDIR="$(mktemp -d)"
pushd "$1/components" || exit 1
envsubst < ./minecraft.yml > $WORKDIR/minecraft.yml
envsubst <  ./unsup.yml > $WORKDIR/unsup.yml
if [[ $MODLOADER == "forge" ]]; then
  envsubst <  ./forge.yml > $WORKDIR/loader.yml
  echo "" > $WORKDIR/extra.yml
elif [[ $MODLOADER == "fabric" ]]; then
  echo "Not yet implimented for fabric loader!"
  exit 1
elif [[ $MODLOADER == "vanilla" ]]; then
  echo "" > $WORKDIR/loader.yml
  echo "" > $WORKDIR/extra.yml
else
  echo "Unsupported modloader"
  exit 1
fi

if [[ $LWJGL_MAJOR == "3" ]]; then
  envsubst <  ./lwjgl3.yml > $WORKDIR/lwjgl.yml
elif [[ $LWJGL_MAJOR == "2" ]]; then
  envsubst <  ./lwjgl.yml > $WORKDIR/lwjgl.yml
else
  echo "Unsupported lwjgl"
  exit 1
fi
pushd $WORKDIR || exit 1
# Generate merged file
yq -o yaml -I 2 eval-all '{"components": [.]}' lwjgl.yml minecraft.yml loader.yml extra.yml unsup.yml > merged.yml
awk -v RS="\O" -v ORS="" '{
  gsub("---\ncomponents:\n", "")
}7' ./merged.yml > processed.yml
echo "formatVersion: 1" >> processed.yml
yq -o json ./processed.yml > mmc-pack.json
mkdir patches
mkdir minecraft
popd || exit 1
popd || exit 1
pushd "$1/patches" || exit 1
envsubst < ./com.unascribed.unsup.yml | yq -o json e > $WORKDIR/patches/com.unascribed.unsup.json
popd || exit 1
cp ./unsup.ini $WORKDIR/minecraft/unsup.ini
cat <<EOF > $WORKDIR/instance.cfg
[General]
ConfigVersion=1.2
InstanceType=OneSix
iconKey=default
name=$(yq '.name' ./pack.toml)
EOF
pushd $WORKDIR || exit 1
zip -r ./instance.zip ./instance.cfg ./minecraft ./patches ./mmc-pack.json
popd || exit 1
mv $WORKDIR/instance.zip $2