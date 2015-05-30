---
title: Evolution, Evolution-MAPI, and Exchange 2010
layout: post
permalink: /blogs/a/entry/evolution_evolution_mapi_and_exchange
---

### The Problem

Exchange 2010 requires encrypted RPC. As a result, the versions of Evolution and Evolution-MAPI in Debian Unstable and Ubuntu can't support Exchange 2010. When one attempts to authenticate to a 2010 host, the result is the error "MAPI_E_LOGON_FAILED".

Only the newest version of libmapi, 0.9, supports the necessary encryption. I decided to build my own packages in order to get libmapi 0.9.

### The Solution

Updating libmapi to 0.9 gets me Exchange 2010 support, but it meant building new packages for Samba 4 (alpha 11), Evolution (2.31.1), gnome-pilot (2.0.17) and Evolution-mapi (0.31.1).

Unfortunately, out of the box, Evolution-MAPI 0.31 still doesn't handle adding the encryption flag to accounts' MAPI profiles. A short patch was required in order to force the "seal: true" attribute to be added when it creates the MAPI profile:  
{% highlight diff %}
./src/libexchangemapi/exchange-mapi-connection.c
2010-05-12 18:39:32.000000000 -0400
@@ -3325,6 +3325,9 @@
        mapi_profile_add_string_attr(profname, "workstation", workstation);
        mapi_profile_add_string_attr(profname, "domain", domain);

+       /* HACK HACK HACK */
+       mapi_profile_add_string_attr(profname, "seal", "true");
+
        /* This is only convenient here and should be replaced at some point */
        mapi_profile_add_string_attr(profname, "codepage", "0x4e4");
        mapi_profile_add_string_attr(profname, "language", "
{% endhighlight %}

Important note: the Exchange 2010-required encryption is hardcoded on new MAPI accounts created with these packages. I'm not sure whether newly-created accounts will work with Exchange 2007!

### The Packages

**Update, 22 Jan 2010**: I have removed the pre-compiled packages. Debian, Ubuntu, and Evolution have all moved too far for them to be useful to anyone. The above patch should still work. See the note on ldbedit for how to configure an account after patching Evolution.

The first thing to understand is that these packages are alpha- and beta-quality software. It's a preview release of evolution, an alpha of samba, a beta of libmapi, etc. There will be bugs.

The second thing to keep in mind is that I am not a DD, and my packaging work is not of high quality. Use these packages AT YOUR OWN RISK. I will not be responsible if they nuke your mailbox, trash your system, ruin your fileserver, etc. I would STRONGLY RECOMMEND purging them before upgrading your system -- I can't guarantee that the official debian/ubuntu packages will make a clean upgrade!

With that warning, if you would still like to use them, add this line to your /etc/apt/sources.list
{% highlight text %}
# Evolution packages
deb http://www.jones.ec/debian/evolution sid main
{% endhighlight %}

These packages should probably work correctly on Debian Unstable (sid), Ubuntu 10.04 ("Lucid"), or Ubuntu 10.10 ("Maverick"). I only built x86 versions because I only have x86 Debian systems at home and at work. Don't ask me for x64 copies.

After adding to sources.list, installation is straightforward:
  
{% highlight bash %}
sudo apt-get update

sudo apt-get -t sid install evolution evolution-common \
evolution-plugins evolution-plugins-experimental \
libevolution libevolution evolution-data-server \
evolution-data-server-common libcamel1.2-15 \
libebackend1.2-0 libebook1.2-9 libecal1.2-7 \
libedata-book1.2-2 libedata-cal1.2-7 \
libedataserver1.2-11 libedataserverui1.2-8 \
libegroupwise1.2-13 libgdata7 libmapi0 \
libdcerpc0
{% endhighlight %}

After you've installed the newest evolution/libmapi/evolution-mapi, if you have an existing Evolution MAPI account configured, you can use this procedure to add the "Seal: true" attribute for Exchange 2010 encryption. A fellow on gimpnet #evo-mapi, kerihuel, helped me out on this one:

1. Shut down evolution and evolution-data-server, forcibly if necessary. Evolution-data-server runs in the backround even when evolution is not running! (Easiest way to force kill: ```killall -9 `pgrep evolution` ```)

2. Run ```ldbedit -H ~/.evolution/mapi_profiles.ldb```

3. Within the profile LDB entry, append "seal: true"

4. Save, quit and re-run evolution

