Name:		mod-ui
Version:	0.99.8
Release:	2%{?dist}
Summary:	Mod-devices pedalboard web portal

License:	GNU General Public License
URL:		https://moddevices.com/
Source0:	v0.99.8-el7.tar.gz
Patch0:		mod-ui-sh.patch
Patch1:		mod-ui-mod-hmi.patch
Patch2:		mod-ui-server.patch
Patch3:		mod-ui-html-index.patch

Requires:	python(abi) >= 3.0, python36-pillow, python36-tornado

# Turn off the brp-python-bytecompile script
%global __os_install_post %(echo '%{__os_install_post}' | sed -e 's!/usr/lib[^[:space:]]*/brp-python-bytecompile[[:space:]].*$!!g')

%description
This is the UI for the MOD software. It's a webserver that delivers an HTML5
interface and communicates with mod-host.

%prep
%setup -n mod-ui
%patch0 -p0
%patch1 -p0
%patch2 -p0
%patch3 -p0

%build
cd utils
make

%install
mkdir -p %{buildroot}/opt/mod-ui/bin
cp server.py %{buildroot}/opt/mod-ui/
cp mod-ui.sh %{buildroot}/opt/mod-ui/bin/
cp -a mod %{buildroot}/opt/mod-ui/
cp -a html %{buildroot}/opt/mod-ui/
cp -a modtools %{buildroot}/opt/mod-ui/
mkdir %{buildroot}/opt/mod-ui/utils
cp utils/libmod_utils.so %{buildroot}/opt/mod-ui/utils/

%files
%attr(755, root, -) /opt/mod-ui/server.py
%attr(755, root, -) /opt/mod-ui/bin/mod-ui.sh
/opt/mod-ui/mod
/opt/mod-ui/html
/opt/mod-ui/modtools
/opt/mod-ui/utils

%changelog
* Sat May 1 2021 JWBotwright <john@johnandlara.plus.com> 0.99.8-2
- Update to git commit 2376893
* Sat Apr 3 2021 JWBotwright <john@johnandlara.plus.com> 0.99.8-1
- Initial version
