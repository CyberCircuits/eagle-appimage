VERSION=9.6.2

define _apprun =
cat > AppDir/AppRun <<\EOF
#!/bin/sh
HERE="$(dirname "$(readlink -f "${0}")")"
export LD_LIBRARY_PATH="${HERE}"/usr/lib/x86_64-linux-gnu/:"${HERE}"/lib/x86_64-linux-gnu/:"${HERE}"/usr/lib/:"${HERE}"/lib/:"${HERE}"/opt/eagle/lib/:$LD_LIBRARY_PATH
cd "${HERE}/usr"
exec "${HERE}/opt/eagle/eagle" "$@"
EOF
chmod a+x AppDir/AppRun
endef
export apprun = $(value _apprun)

define _desktop =
cat > AppDir/eagle.desktop <<\EOF
[Desktop Entry]
Categories=Development;Electronics;
Comment=Scriptable EDA application with schematic capture, PCB layout, auto-router and CAM
Type=Application
Icon=eagle
Exec=eagle "%f"
Name=EAGLE
X-AppImage-Name=EAGLE
X-AppImage-Version=
EOF
endef
export desktop = $(value _desktop)

define _metainfo =
cat > AppDir/usr/share/metainfo/eagle.appdata.xml <<\EOF
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>eagle</id>
  <metadata_license>BSD</metadata_license>
  <project_license>LicenseRef-proprietary=http://www.autodesk.com/products/eagle/subscribe</project_license>
  <name>EAGLE</name>
  <summary>Easily Applicable Graphical Layout Editor</summary>

  <description>
    <p>
      EAGLE contains a schematic editor, for designing circuit diagrams.
      Schematics are stored in files with .SCH extension, parts are defined
      in device libraries with .LBR extension. Parts can be placed on many
      sheets and connected together through ports.
    </p>
  </description>

  <launchable type="desktop-id">eagle.desktop</launchable>

  <url type="homepage">https://www.autodesk.com/products/eagle</url>
  <project_group>EAGLE</project_group>

  <provides>
    <binary>eagle</binary>
  </provides>

  <releases>
    <release version="9.6.2" date="2020-05-07">
      <description>
        <p>See: http://eagle.autodesk.com/eagle/release-notes</p>
      </description>
    </release>
  </releases>
</component>
EOF
endef
export metainfo = $(value _metainfo)

.PHONY: all
all: appdir; @eval "$$apprun"
	@eval "$$desktop"
	@eval "$$metainfo"
	@docker build -t eagle-appimage .
	@docker run --rm -it \
		--cap-add SYS_ADMIN \
		--security-opt apparmor:unconfined \
		--privileged \
		--mount src=$$PWD,target=/appimage,type=bind \
		--cap-add SYS_ADMIN \
		--cap-add MKNOD \
		--device /dev/fuse:mrw \
		eagle-appimage \
		sh -c "\
			cd /appimage && \
			wget -q -O /tmp/eagle.tar.gz https://eagle-updates.circuits.io/downloads/9_6_2/Autodesk_EAGLE_9.6.2_English_Linux_64bit.tar.gz && \
			tar -zxf /tmp/eagle.tar.gz --strip-components=1 -C AppDir/opt/eagle && \
			rm AppDir/opt/eagle/lib/libxcb* && \
			cp AppDir/opt/eagle/bin/eagle-logo.png AppDir/eagle.png && \
			LINUXDEPLOY_OUTPUT_VERSION="${VERSION}" linuxdeploy \
				--appdir AppDir/ \
				--icon-file=AppDir/eagle.png \
				--executable=AppDir/opt/eagle/eagle \
				--output appimage && \
			chmod 0777 AppDir -R"

.PHONY: appdir
appdir:
	@mkdir -p AppDir/opt/eagle AppDir/usr/share/metainfo
