package("ncurses")
    set_homepage("https://www.gnu.org/software/ncurses/")
    set_description("A free software emulation of curses.")

    set_sourcedir("$(projectdir)/ncurses-6.0")
    
    -- add_urls("https://ftpmirror.gnu.org/ncurses/ncurses-$(version).tar.gz",
    --          "https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$(version).tar.gz",
    --         "https://invisible-mirror.net/archives/ncurses/ncurses-$(version).tar.gz")
    add_versions("6.0", "f551c24b30ce8bfb6e96d9f59b42fbea30fa3a6123384172f9e7284bcf647260")

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {
            "--with-shared=no",
            "--with-cxx-shared=no",

            "--with-gpm=no",
            "--without-gpm",
            "--without-tests",
            "--without-manpages",
            "--without-ada",
            "--without-cxx",
            "--without-cxx-binding",
            "--without-debug",
            "--without-progs",
            "--without-profile",
            "--without-libtool",
            "--enable-pc-files",
            "--enable-colorfgbg",
            "--enable-hard-tabs",
            "--without-sysmouse",
            --"--enable-ext-mouse",
            --"--enable-overwrite",!!!!
            --"--enable-rpath"
            "--enable-xmc-glitch",
            "--disable-stripping",
            "--disable-wattr-macros",
            "--with-ospeed=unsigned",
            "--with-pkg-config-libdir=" .. package:installdir() .. "/lib/pkgconfig",
            --"--with-terminfo-dirs=%{_sysconfdir}/terminfo:%{_datadir}/terminfo",
            "--with-termlib=yes",
            "--with-ticlib=yes",
            "--with-xterm-kbs=DEL",
            "--enable-ext-colors=yes",
            "--enable-sigwinch=yes",
            "--with-sp-funcs=yes",
            "--disable-echo",
            "--enable-widec=yes",
            "--build=x86_64-linux-gnu"
            
        }
        import("package.tools.autoconf").install(package, configs, 
            {
                arflags = {"-curvU"},
                cflags = {"-O2", "-fPIC"},
                cxxflags = {"-Wl,--no-undefined"}
                --, "-Wl,-Bsymbolic"
            }
        )
    end)
package_end()


package("dialog")
	set_homepage("http://invisible-island.net/dialog/dialog.html")
	set_description("A utility for creating TTY dialog boxes")
	-- add_urls("https://invisible-island.net/archives/dialog/dialog-$(version).tgz")
	add_versions("1.2-20130523", "c8d114b7698022bcbd6c88f3c0b2296b0e846c60c5ed6bd28f86dd72b94fd36d")
	set_sourcedir("$(projectdir)/dialog-1.2-20130523")
    add_deps("ncurses")

	on_install("linux", "macosx", "bsd", function (package)
		import("package.tools.autoconf")

		local curses_dir = path.join(os.projectdir(), "build", ".packages", "n", "ncurses", "6.0", "4e0143c97b65425b855ad5fd03038b6a")
		local configs = {
			"--enable-nls",
			"--disable-echo",
			"--with-curses-color",
			"--with-ncursesw",
			"--enable-widec",
			"--with-curses-dir=" .. curses_dir

		}
		buildenvs = autoconf.buildenvs(package)
		if os.exists("makefile") then
			os.vrunv("make clean", {envs = buildenvs})
            os.rm("makefile")
		end
		print(buildenvs)
		os.vrunv("./configure", configs)
		io.replace("makefile", "LIBS		=", "LIBS    = -lncursesw -ltinfow -lticw -lpanelw -lmenuw -lformw")
		io.replace("makefile", "EXTRA_CFLAGS	=", "CPPFLAGS    += -g2 -DHAVE_COLOR")
		os.vrunv("make -j8", {envs = buildenvs})

		os.cp("dialog", package:installdir("bin"))
	end)
package_end()


add_requires("ncurses", { system = false })
add_requires("dialog 1.2-20130523", {alias = "dialog", system = false })

target("phony")
    set_kind("binary")
    add_packages("dialog", "ncurses")
    add_files("main.c")

    on_uninstall(function(target)
        os.exec("xmake clean --all")
        os.tryrm(path.join(os.projectdir(), "build"))
    end)
target_end()